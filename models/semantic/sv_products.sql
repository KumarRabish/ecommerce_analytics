select product_key, sku, product_name, category, subcategory, brand, list_price, is_active
from {{ ref('dim_products') }}
