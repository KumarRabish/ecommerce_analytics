-- Line-level refunds must not exceed the line's net amount.

-- Total active refunds must not exceed the order item's net amount.

WITH active_refunds AS (
    SELECT
        r.order_item_id,
        SUM(r.refund_amount_usd) AS total_refund_amount_usd
    FROM {{ ref('fct_refunds') }} r
    WHERE NOT COALESCE(r.is_deleted, FALSE)
    GROUP BY r.order_item_id
),

active_order_items AS (
    SELECT
        i.order_item_id,
        i.net_amount_usd
    FROM {{ ref('fct_order_items') }} i
    WHERE NOT COALESCE(i.is_deleted, FALSE)
)

SELECT
    r.order_item_id,
    r.total_refund_amount_usd,
    i.net_amount_usd,
    r.total_refund_amount_usd - i.net_amount_usd
        AS excess_refund_amount_usd
FROM active_refunds r
JOIN active_order_items i
    ON i.order_item_id = r.order_item_id
WHERE r.total_refund_amount_usd > i.net_amount_usd + 0.01
