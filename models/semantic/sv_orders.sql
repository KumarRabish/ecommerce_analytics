select
    order_id, customer_key, order_date, ordered_at, order_status, channel,
    currency_code, shipping_country, is_first_order, is_revenue_recognized, shipping_fee_usd
from {{ ref('fct_orders') }}
where not is_deleted and not is_test_order
