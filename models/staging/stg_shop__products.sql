with latest as (
    select * from {{ source('shop', 'products') }}
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number                         as product_id,
    upper(trim(sku))                   as sku,
    trim(name)                         as product_name,
    initcap(trim(category))            as category,
    initcap(trim(subcategory))         as subcategory,
    initcap(trim(brand))               as brand,
    unit_cost::number(18, 2)           as unit_cost,
    list_price::number(18, 2)          as list_price,
    coalesce(is_active, true)          as is_active,
    coalesce(_fivetran_deleted, false) as is_deleted,
    _fivetran_synced                   as synced_at
from latest
