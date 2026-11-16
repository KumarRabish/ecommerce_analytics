select order_id, order_date
from {{ ref('fct_orders') }}
where order_date > dateadd(day, 1, current_date)
