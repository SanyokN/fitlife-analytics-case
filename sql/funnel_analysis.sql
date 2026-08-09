-- Calculate funnel conversion rates (Registration -> Trial -> Paid) by traffic source
SELECT 
    u.source,
    COUNT(DISTINCT u.id) AS total_users,
    COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END) AS trials,
    COUNT(DISTINCT CASE WHEN t.payment_status = 'completed' THEN u.id END) AS paid,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END) * 100.0 
        / COUNT(DISTINCT u.id), 2
    ) AS cr_to_trial,
    ROUND(
        COUNT(DISTINCT CASE WHEN t.payment_status = 'completed' THEN u.id END) * 100.0 
        / NULLIF(COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END), 0), 2
    ) AS cr_trial_to_paid
FROM users u
LEFT JOIN activity a 
    ON u.id = a.user_id 
   AND a.event_name = 'trial_activated'
LEFT JOIN transactions t 
    ON u.id = t.user_id 
   AND t.payment_status = 'completed'
GROUP BY u.source
ORDER BY total_users DESC;
