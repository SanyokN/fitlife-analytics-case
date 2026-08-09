WITH user_first_activity AS (
    SELECT 
        user_id,
        DATE_TRUNC('week', MIN(event_date::date))::date AS cohort_week
    FROM activity
    GROUP BY user_id
),
cohort_sizes AS (
    SELECT 
        cohort_week,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_activity
    GROUP BY cohort_week
),
weeks_grid AS (
    SELECT 
        cs.cohort_week,
        cs.cohort_size,
        w.week_number
    FROM cohort_sizes cs
    CROSS JOIN generate_series(0, 8) AS w(week_number)
)
SELECT 
    g.cohort_week,
    g.cohort_size,
    g.week_number,
    COUNT(DISTINCT t.user_id) AS active_paying_users,
    ROUND(
        COALESCE(COUNT(DISTINCT t.user_id)::numeric / NULLIF(g.cohort_size, 0) * 100, 0), 2
    ) AS retention_rate_pct
FROM weeks_grid g
JOIN user_first_activity f ON f.cohort_week = g.cohort_week
LEFT JOIN transactions t 
    ON f.user_id = t.user_id
   AND t.payment_status = 'completed'
   AND DATE_TRUNC('week', t.payment_date::date)::date = g.cohort_week + (g.week_number * INTERVAL '1 week')
GROUP BY g.cohort_week, g.cohort_size, g.week_number
ORDER BY g.cohort_week, g.week_number;
