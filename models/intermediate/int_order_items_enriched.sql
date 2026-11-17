select
    i.order_item_id,
    i.order_id,
    o.customer_id,
    i.product_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    o.channel,
    o.currency_code,
    o.is_test_order,
    o.is_revenue_recognized,
    i.quantity,
    round(i.unit_price * o.usd_rate, 4)                                  as unit_price_usd,
    round(i.quantity * i.unit_price * o.usd_rate, 2)                     as gross_amount_usd,
    round(i.discount_amount * o.usd_rate, 2)                             as discount_amount_usd,
    -- round((i.quantity * i.unit_price - i.discount_amount) * o.usd_rate, 2) as net_amount_usd,
    round(i.quantity * i.unit_price * o.usd_rate, 2) - round(i.discount_amount * o.usd_rate, 2) as net_amount_usd,
    (i.is_deleted or o.is_deleted)                                       as is_deleted,
    greatest(i.synced_at, o.synced_at)                                   as last_changed_at
from {{ ref('stg_shop__order_items') }} i
join {{ ref('int_orders_fx') }} o
    on o.order_id = i.order_id
