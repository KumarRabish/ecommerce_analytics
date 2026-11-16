-- Exactly one first order per known customer (guards the is_first_order logic).
select customer_key, count(*) as first_orders
from {{ ref('fct_orders') }}
where is_first_order and not is_deleted and not is_test_order and customer_key <> -1
group by 1
having count(*) > 1
