-- Line-level refunds must not exceed the line's net amount.
select r.refund_id, r.refund_amount_usd, i.net_amount_usd
from {{ ref('fct_refunds') }} r
join {{ ref('fct_order_items') }} i on i.order_item_id = r.order_item_id
where not r.is_deleted
  and r.refund_amount_usd > i.net_amount_usd + 0.01
