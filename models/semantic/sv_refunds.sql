select
    refund_id,
    order_id,
    refund_date,
    refund_amount_usd,
    refund_reason
from {{ ref('fct_refunds') }}
where not is_deleted and not is_test_order
