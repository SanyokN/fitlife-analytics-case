WITH user_first_activity AS (
    -- 1. Determine the first activity date and month (cohort) for each user
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(created_at::date))::date AS cohort_month
    FROM events
    GROUP BY user_id
),

user_activities AS (
    -- 2. Extract all unique active months for each user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', created_at::date)::date AS activity_month
    FROM events
),

cohort_sizes AS (
    -- 3. Calculate the total size of each cohort (Month 0)
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_activity
    GROUP BY cohort_month
)

-- 4. Aggregate data and calculate Monthly Retention Rate %
SELECT 
    f.cohort_month,
    cs.cohort_size,
    -- Calculate difference in months between activity month and registration month
    (
        EXTRACT(YEAR FROM AGE(a.activity_month, f.cohort_month)) * 12 + 
        EXTRACT(MONTH FROM AGE(a.activity_month, f.cohort_month))
    )::int AS month_number,
    COUNT(DISTINCT f.user_id) AS active_users,
    ROUND(
        COUNT(DISTINCT f.user_id)::numeric / cs.cohort_size * 100, 2
    ) AS retention_rate_pct
FROM user_first_activity f
JOIN user_activities a 
    ON f.user_id = a.user_id 
   AND a.activity_month >= f.cohort_month
JOIN cohort_sizes cs 
    ON f.cohort_month = cs.cohort_month
GROUP BY 1, 2, 3
ORDER BY 1, 3;