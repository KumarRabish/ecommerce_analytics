select customer_key, country, state, city, marketing_opt_in, first_order_date, lifetime_orders
from {{ ref('dim_customers') }}
