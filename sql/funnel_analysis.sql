-- Profile execution plan, timing, and memory/disk usage
EXPLAIN (ANALYZE, BUFFERS, TIMING)

WITH user_events AS (
    -- CTE 1: Get the first timestamp for each key step per user
    SELECT 
        user_id,
        MIN(CASE WHEN event_name = 'page_view' THEN event_date END) AS viewed_at,
        MIN(CASE WHEN event_name = 'cart_add' THEN event_date END) AS added_to_cart_at,
        MIN(CASE WHEN event_name = 'checkout' THEN event_date END) AS checkout_at,
        MIN(CASE WHEN event_name = 'purchase' THEN event_date END) AS purchased_at
    FROM activity
    GROUP BY user_id
),

funnel_counts AS (
    -- CTE 2: Count distinct users who reached each sequential funnel step
    SELECT 
        COUNT(user_id) AS total_users,
        COUNT(CASE WHEN viewed_at IS NOT NULL THEN user_id END) AS step_1_view,
        COUNT(CASE WHEN added_to_cart_at IS NOT NULL AND added_to_cart_at >= viewed_at THEN user_id END) AS step_2_cart,
        COUNT(CASE WHEN checkout_at IS NOT NULL AND checkout_at >= added_to_cart_at THEN user_id END) AS step_3_checkout,
        COUNT(CASE WHEN purchased_at IS NOT NULL AND purchased_at >= checkout_at THEN user_id END) AS step_4_purchase
    FROM user_events
)

-- Main Query: Calculate conversion rates between funnel stages
SELECT 
    total_users,
    step_1_view,
    step_2_cart,
    step_3_checkout,
    step_4_purchase,
    -- Step-by-step conversion rates
    ROUND((step_2_cart::numeric / NULLIF(step_1_view, 0)) * 100, 2) AS view_to_cart_pct,
    ROUND((step_3_checkout::numeric / NULLIF(step_2_cart, 0)) * 100, 2) AS cart_to_checkout_pct,
    ROUND((step_4_purchase::numeric / NULLIF(step_3_checkout, 0)) * 100, 2) AS checkout_to_purchase_pct,
    -- Total end-to-end conversion rate
    ROUND((step_4_purchase::numeric / NULLIF(step_1_view, 0)) * 100, 2) AS overall_conversion_pct
FROM funnel_counts;