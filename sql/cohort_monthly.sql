-- Profile execution plan, timing, and memory/disk usage
EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_cohorts AS (
    -- CTE 1: Determine the cohort (first action month) for each user
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(event_date)) AS cohort_month
    FROM activity
    GROUP BY user_id
),

user_activities AS (
    -- CTE 2: Get all unique activity months per user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', event_date) AS activity_month
    FROM activity
)

-- Main Query: Calculate cohort size and retention matrix by month (Cohort Lifetime)
SELECT 
    c.cohort_month::date AS cohort_month,
    -- Calculate month offset (0 = registration month, 1 = next month)
    (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12 +
    (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) AS month_number,
    COUNT(DISTINCT a.user_id) AS active_users
FROM user_cohorts c
JOIN user_activities a ON c.user_id = a.user_id
GROUP BY 1, 2
ORDER BY 1, 2;