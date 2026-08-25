-- Profile execution plan, timing, and memory/disk usage
EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_first_week AS (
    -- CTE 1: Determine cohort week and geography from users table
    SELECT 
        id AS user_id,
        country_code,
        DATE_TRUNC('week', registration_date)::date AS cohort_week
    FROM users
),

weekly_activity AS (
    -- CTE 2: Get all unique activity weeks per user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('week', event_date)::date AS activity_week
    FROM activity
),

cohort_sizes AS (
    -- CTE 3: Calculate base size per weekly cohort and country
    SELECT 
        cohort_week,
        country_code,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_week
    GROUP BY cohort_week, country_code
)

-- Main Query: Weekly retention matrix calculation by country
SELECT 
    cs.country_code,
    cs.cohort_week,
    cs.cohort_size,
    -- Calculate week offset (0 = registration week, 1 = next week)
    FLOOR((wa.activity_week - cs.cohort_week) / 7)::int AS week_number,
    COUNT(DISTINCT fw.user_id) AS active_users,
    ROUND((COUNT(DISTINCT fw.user_id)::numeric / cs.cohort_size) * 100, 2) AS retention_rate_pct
FROM cohort_sizes cs
JOIN user_first_week fw 
    ON cs.cohort_week = fw.cohort_week 
   AND cs.country_code = fw.country_code
LEFT JOIN weekly_activity wa 
    ON fw.user_id = wa.user_id
GROUP BY cs.country_code, cs.cohort_week, cs.cohort_size, 4
ORDER BY cs.country_code, cs.cohort_week, 4;