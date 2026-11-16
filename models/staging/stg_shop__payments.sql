with latest as (
    select * from {{ source('shop', 'payments') }}
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number                         as payment_id,
    order_id::number                   as order_id,
    lower(trim(method))                as payment_method,
    lower(trim(status))                as payment_status,
    amount::number(18, 2)              as amount,
    {{ utc_ntz('paid_at') }}           as paid_at,
    {{ utc_ntz('paid_at') }}::date     as paid_date,
    coalesce(_fivetran_deleted, false) as is_deleted,
    _fivetran_synced                   as synced_at
from latest
