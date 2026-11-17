with latest as (
    select * from {{ source('shop', 'refunds') }}
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number(38, 0)                        as refund_id,
    order_id::number(38, 0)                   as order_id,
    order_item_id::number(38, 0)              as order_item_id,    -- null = order-level refund
    amount::number(18, 2)              as refund_amount,
    lower(trim(reason))                as refund_reason,
    {{ utc_ntz('refunded_at') }}       as refunded_at,
    {{ utc_ntz('refunded_at') }}::date as refund_date,
    coalesce(_fivetran_deleted, false) as is_deleted,
    _fivetran_synced                   as synced_at
from latest
