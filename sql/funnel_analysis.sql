-- Profile execution plan, timing, and memory/disk usage
EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_funnel AS (
    SELECT 
        u.id AS user_id,
        u.country_code,
        COUNT(DISTINCT a.user_id) AS is_active,
        COUNT(DISTINCT t.user_id) AS is_paying
    FROM users u
    LEFT JOIN activity a ON u.id = a.user_id
    LEFT JOIN transactions t ON u.id = t.user_id
    GROUP BY u.id, u.country_code
),
funnel_summary AS (
    SELECT 
        country_code,
        COUNT(user_id) AS registered_users,
        SUM(is_active) AS active_users,
        SUM(is_paying) AS paying_users
    FROM user_funnel
    GROUP BY country_code
)
SELECT 
    country_code,
    registered_users,
    active_users,
    paying_users,
    ROUND((active_users::NUMERIC / NULLIF(registered_users, 0)) * 100, 2) AS reg_to_active_pct,
    ROUND((paying_users::NUMERIC / NULLIF(active_users, 0)) * 100, 2) AS active_to_pay_pct,
    ROUND((paying_users::NUMERIC / NULLIF(registered_users, 0)) * 100, 2) AS overall_conversion_pct
FROM funnel_summary
ORDER BY registered_users DESC;