select payment_id, order_id, payment_method, payment_status, payment_amount_usd, paid_date
from {{ ref('fct_payments') }}
where not is_deleted and not is_test_order
