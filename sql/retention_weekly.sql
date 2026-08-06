WITH user_first_activity AS (
    -- 1. Determine the first activity date and week (cohort) for each user
    SELECT 
        user_id,
        DATE_TRUNC('week', MIN(event_date::date))::date AS cohort_week
    FROM activity
    GROUP BY user_id
),

user_activities AS (
    -- 2. Extract all unique active weeks for each user
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('week', event_date::date)::date AS activity_week
    FROM activity
),

cohort_sizes AS (
    -- 3. Calculate the total size of each cohort (Week 0)
    SELECT 
        cohort_week,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_activity
    GROUP BY cohort_week
)

-- 4. Aggregate data and calculate Retention Rate %
SELECT 
    f.cohort_week,
    cs.cohort_size,
    -- Difference in weeks between activity week and registration week
    ((a.activity_week - f.cohort_week) / 7)::int AS week_number,
    COUNT(DISTINCT f.user_id) AS active_users,
    ROUND(
        COUNT(DISTINCT f.user_id)::numeric / cs.cohort_size * 100, 2
    ) AS retention_rate_pct
FROM user_first_activity f
JOIN user_activities a 
    ON f.user_id = a.user_id 
   AND a.activity_week >= f.cohort_week
JOIN cohort_sizes cs 
    ON f.cohort_week = cs.cohort_week
GROUP BY 1, 2, 3
ORDER BY 1, 3;
