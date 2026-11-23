-- fct_orders must equal the sum of its own lines. Catches the classic incremental
-- bug where a change to a child table never refreshes the parent.
select
    o.order_id,
    o.net_amount_usd                 as order_net,
    coalesce(i.item_net, 0)          as items_net
from {{ ref('fct_orders') }} o
left join (
    select order_id, sum(net_amount_usd) as item_net
    from {{ ref('fct_order_items') }}
    where not is_deleted
    group by 1
) i on i.order_id = o.order_id
where not o.is_deleted
  and abs(o.net_amount_usd - coalesce(i.item_net, 0)) > 0.01
