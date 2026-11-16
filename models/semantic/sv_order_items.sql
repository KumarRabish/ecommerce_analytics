select
    order_item_id, order_id, product_key, quantity, unit_price_usd,
    gross_amount_usd, discount_amount_usd, net_amount_usd, cogs_usd
from {{ ref('fct_order_items') }}
where not is_deleted and not is_test_order and is_revenue_recognized