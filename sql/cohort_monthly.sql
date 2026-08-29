-- Profile execution plan, timing, and memory/disk usage
-- EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_cohorts AS (
    -- CTE 1: Determine the cohort month and geography from users table
    SELECT 
        id AS user_id,
        country_code,
        DATE_TRUNC('month', registration_date)::date AS cohort_month
    FROM users
),

user_activities AS (
    -- CTE 2: Get all unique activity months per user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', event_date)::date AS activity_month
    FROM activity
),

cohort_sizes AS (
    -- CTE 3: Calculate initial cohort size per month and country
    SELECT 
        cohort_month,
        country_code,
        COUNT(DISTINCT user_id) AS total_users
    FROM user_cohorts
    GROUP BY cohort_month, country_code
)

-- Main Query: Calculate retention matrix with country breakdown
SELECT 
    cs.country_code,
    cs.cohort_month,
    cs.total_users AS cohort_size,
    (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM cs.cohort_month)) * 12 +
    (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM cs.cohort_month)) AS month_number,
    COUNT(DISTINCT c.user_id) AS active_users,
    ROUND(COUNT(DISTINCT c.user_id)::NUMERIC / cs.total_users * 100, 2) AS retention_rate_pct
FROM cohort_sizes cs
JOIN user_cohorts c 
    ON cs.cohort_month = c.cohort_month 
   AND cs.country_code = c.country_code
LEFT JOIN user_activities a 
    ON c.user_id = a.user_id
GROUP BY cs.country_code, cs.cohort_month, cs.total_users, 4
ORDER BY cs.country_code, cs.cohort_month, 4;