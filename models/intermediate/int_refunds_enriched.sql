select
    r.refund_id,
    r.order_id,
    r.order_item_id,
    r.refund_date,
    r.refunded_at,
    r.refund_reason,
    round(r.refund_amount * o.usd_rate, 2)  as refund_amount_usd,
    o.is_test_order,
    (r.is_deleted or o.is_deleted)          as is_deleted,
    greatest(r.synced_at, o.synced_at)      as last_changed_at
from {{ ref('stg_shop__refunds') }} r
join {{ ref('int_orders_fx') }} o
    on o.order_id = r.order_id
