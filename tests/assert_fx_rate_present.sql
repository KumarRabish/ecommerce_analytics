-- A missing rate must fail loudly instead of silently converting at 1.0.
select order_id, currency_code, order_date
from {{ ref('int_orders_fx') }}
where usd_rate is null
