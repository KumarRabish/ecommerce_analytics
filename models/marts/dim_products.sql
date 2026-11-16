select
    product_id      as product_key,
    sku,
    product_name,
    category,
    subcategory,
    brand,
    unit_cost,
    list_price,
    is_active
from {{ ref('stg_shop__products') }}
where not is_deleted
