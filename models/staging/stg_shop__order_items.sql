with latest as (
    select * from {{ source('shop', 'order_items') }}
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number                                   as order_item_id,
    order_id::number                             as order_id,
    product_id::number                           as product_id,
    quantity::number                             as quantity,
    unit_price::number(18, 2)                    as unit_price,
    coalesce(discount_amount, 0)::number(18, 2)  as discount_amount,
    coalesce(_fivetran_deleted, false)           as is_deleted,
    _fivetran_synced                             as synced_at
from latest
