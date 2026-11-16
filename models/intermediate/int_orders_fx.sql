select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    o.channel,
    o.currency_code,
    o.shipping_country,
    o.is_test_order,
    o.shipping_fee,
    o.is_deleted,
    o.synced_at,
    o.order_status in ('paid', 'shipped', 'delivered') as is_revenue_recognized,
    fx.usd_rate
from {{ ref('stg_shop__orders') }} o
asof join {{ ref('fx_rates') }} fx
    match_condition (o.order_date >= fx.rate_date)
    on o.currency_code = fx.currency_code
