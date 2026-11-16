with source as (
    select * from {{ source('shop', 'orders') }}
),

latest as (
    select * from source
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number                                  as order_id,
    coalesce(customer_id, -1)::number           as customer_id,      -- -1 = guest / unknown customer
    lower(trim(status))                         as order_status,
    upper(trim(currency))                       as currency_code,
    {{ utc_ntz('created_at') }}                 as ordered_at,
    {{ utc_ntz('created_at') }}::date           as order_date,
    lower(coalesce(trim(channel), 'unknown'))   as channel,
    coalesce(is_test, false)                    as is_test_order,
    upper(trim(shipping_country))               as shipping_country,
    coalesce(shipping_fee, 0)::number(18, 2)    as shipping_fee,
    coalesce(_fivetran_deleted, false)          as is_deleted,
    _fivetran_synced                            as synced_at
from latest
