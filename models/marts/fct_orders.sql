-- depends_on: {{ ref('stg_shop__orders') }}
-- depends_on: {{ ref('stg_shop__order_items') }}
-- depends_on: {{ ref('stg_shop__refunds') }}

{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    cluster_by=['order_date'],
    on_schema_change='append_new_columns'    
) }}

with
{% if is_incremental() %}
changed_orders as (
    select order_id from {{ ref('stg_shop__orders') }}      where synced_at >= {{ watermark() }}
    union
    select order_id from {{ ref('stg_shop__order_items') }} where synced_at >= {{ watermark() }}
    union
    select order_id from {{ ref('stg_shop__refunds') }}     where synced_at >= {{ watermark() }}
),
{% endif %}

orders as (
    select * from {{ ref('int_orders_fx') }}
    where true {{ changed_orders_filter() }}
),

-- aggregate children to the ORDER grain BEFORE joining (prevents fan-out)
items as (
    select
        order_id,
        sum(iff(is_deleted, 0, gross_amount_usd))    as gross_amount_usd,
        sum(iff(is_deleted, 0, discount_amount_usd)) as discount_amount_usd,
        sum(iff(is_deleted, 0, net_amount_usd))      as net_amount_usd,
        sum(iff(is_deleted, 0, quantity))            as units,
        count_if(not is_deleted)                     as item_count,
        max(last_changed_at)                         as items_changed_at   -- includes deleted rows on purpose
    from {{ ref('int_order_items_enriched') }}
    where true {{ changed_orders_filter() }}
    group by 1
),

refunds as (
    select
        order_id,
        sum(iff(is_deleted, 0, refund_amount_usd))   as refund_amount_usd,
        max(last_changed_at)                         as refunds_changed_at
    from {{ ref('int_refunds_enriched') }}
    where true {{ changed_orders_filter() }}
    group by 1
),

joined as (
    select
        o.order_id,
        o.customer_id                                  as customer_key,
        o.order_date,
        o.ordered_at,
        o.order_status,
        o.channel,
        o.currency_code,
        o.shipping_country,
        o.is_test_order,
        o.is_revenue_recognized,
        round(o.shipping_fee * o.usd_rate, 2)          as shipping_fee_usd,
        coalesce(i.item_count, 0)                      as item_count,
        coalesce(i.units, 0)                           as units,
        coalesce(i.gross_amount_usd, 0)                as gross_amount_usd,
        coalesce(i.discount_amount_usd, 0)             as discount_amount_usd,
        coalesce(i.net_amount_usd, 0)                  as net_amount_usd,
        coalesce(r.refund_amount_usd, 0)               as refund_amount_usd,
        o.is_deleted,
        greatest(
            o.synced_at,
            coalesce(i.items_changed_at,   o.synced_at),
            coalesce(r.refunds_changed_at, o.synced_at)
        )                                              as last_changed_at
    from orders o
    left join items   i on i.order_id = o.order_id
    left join refunds r on r.order_id = o.order_id
)

select
    j.*,
    -- first-order flag comes from the dimension (full history), never from a window over new rows
    coalesce(j.ordered_at = c.first_order_at, false)   as is_first_order,
    current_timestamp()                                as dbt_loaded_at
from joined j
left join {{ ref('dim_customers') }} c
    on c.customer_key = j.customer_key
