{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_item_id',
    cluster_by=['order_date'],
    on_schema_change='append_new_columns'
) }}

select
    e.order_item_id,
    e.order_id,
    e.customer_id                                   as customer_key,
    e.product_id                                    as product_key,
    e.order_date,
    e.ordered_at,
    e.order_status,
    e.channel,
    e.is_test_order,
    e.is_revenue_recognized,
    e.quantity,
    e.unit_price_usd,
    e.gross_amount_usd,
    e.discount_amount_usd,
    e.net_amount_usd,
    e.quantity * coalesce(p.unit_cost, 0)           as cogs_usd,       -- uses CURRENT product cost (see bug C5)
    e.is_deleted,
    e.last_changed_at,
    current_timestamp()                             as dbt_loaded_at
from {{ ref('int_order_items_enriched') }} e
left join {{ ref('dim_products') }} p
    on p.product_key = e.product_id
{% if is_incremental() %}
where e.last_changed_at >= {{ watermark() }}
{% endif %}

