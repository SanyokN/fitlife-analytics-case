WITH user_first_activity AS (
    -- 1. Determine user's first activity/registration month
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(event_date::date))::date AS cohort_month
    FROM activity
    GROUP BY user_id
),

cohort_sizes AS (
    -- 2. Determine the size of each monthly cohort
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_activity
    GROUP BY cohort_month
),

months_grid AS (
    -- 3. Generate a grid of months from 0 to 6 for each cohort
    SELECT 
        cs.cohort_month,
        cs.cohort_size,
        m.month_number
    FROM cohort_sizes cs
    CROSS JOIN generate_series(0, 6) AS m(month_number)
)

-- 4. Calculate Monthly Paying Retention Rate
SELECT 
    g.cohort_month,
    g.cohort_size,
    g.month_number,
    COUNT(DISTINCT t.user_id) AS active_paying_users,
    ROUND(
        COALESCE(COUNT(DISTINCT t.user_id)::numeric / NULLIF(g.cohort_size, 0) * 100, 0), 2
    ) AS retention_rate_pct
FROM months_grid g
JOIN user_first_activity f 
    ON f.cohort_month = g.cohort_month
LEFT JOIN transactions t 
    ON f.user_id = t.user_id
   AND t.payment_status = 'completed'
   AND DATE_TRUNC('month', t.payment_date::date)::date = g.cohort_month + (g.month_number * INTERVAL '1 month')
GROUP BY g.cohort_month, g.cohort_size, g.month_number
ORDER BY g.cohort_month, g.month_number;
