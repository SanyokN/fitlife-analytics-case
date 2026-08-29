-- Profile execution plan, timing, and memory/disk usage
-- EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_summary AS (
    SELECT 
        u.id AS user_id,
        u.source,
        u.country_code,
        COUNT(DISTINCT a.user_id) AS is_trial,
        COUNT(DISTINCT t.user_id) AS is_paid
    FROM users u
    LEFT JOIN activity a ON u.id = a.user_id
    LEFT JOIN transactions t ON u.id = t.user_id
    GROUP BY u.id, u.source, u.country_code
)
SELECT 
    source,
    country_code,
    COUNT(user_id) AS total_users,
    SUM(is_trial) AS trials,
    SUM(is_paid) AS paid,
    ROUND((SUM(is_trial)::NUMERIC / NULLIF(COUNT(user_id), 0)) * 100, 2) AS cr_to_trial,
    ROUND((SUM(is_paid)::NUMERIC / NULLIF(SUM(is_trial), 0)) * 100, 2) AS cr_trial_to_paid,
    ROUND((SUM(is_paid)::NUMERIC / NULLIF(COUNT(user_id), 0)) * 100, 2) AS overall_conversion_pct
FROM user_summary
GROUP BY source, country_code
ORDER BY source, total_users DESC;