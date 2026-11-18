select
    CAST(refund_id as number(38,0)) as refund_id,
    cast(order_id as number(38,0)) as order_id,
    refund_date,
    cast(refund_amount_usd as number(18,0)) as refund_amount_usd,
    refund_reason
from {{ ref('fct_refunds') }}
where not is_deleted and not is_test_order
