-- Profile execution plan, timing, and memory/disk usage
EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_first_week AS (
    -- CTE 1: Determine the cohort (first action week) for each user
    SELECT 
        user_id,
        DATE_TRUNC('week', MIN(event_date))::date AS cohort_week
    FROM activity
    GROUP BY user_id
),

weekly_activity AS (
    -- CTE 2: Get all unique activity weeks per user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('week', event_date)::date AS activity_week
    FROM activity
),

cohort_sizes AS (
    -- CTE 3: Calculate the base size of each weekly cohort
    SELECT 
        cohort_week,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_week
    GROUP BY cohort_week
)

-- Main Query: Weekly retention matrix calculation
SELECT 
    cs.cohort_week,
    cs.cohort_size,
    -- Calculate week offset (0 = registration week, 1 = next week)
    FLOOR((wa.activity_week - cs.cohort_week) / 7)::int AS week_number,
    COUNT(DISTINCT wa.user_id) AS active_users,
    ROUND((COUNT(DISTINCT wa.user_id)::numeric / cs.cohort_size) * 100, 2) AS retention_rate_pct
FROM cohort_sizes cs
JOIN user_first_week fw ON cs.cohort_week = fw.cohort_week
JOIN weekly_activity wa ON fw.user_id = wa.user_id
GROUP BY 1, 2, 3
ORDER BY 1, 3;