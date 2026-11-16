{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='payment_id',
    on_schema_change='append_new_columns'
) }}

select
    p.payment_id,
    p.order_id,
    o.customer_id                                  as customer_key,
    p.payment_method,
    p.payment_status,
    round(p.amount * o.usd_rate, 2)                as payment_amount_usd,
    p.paid_at,
    p.paid_date,
    o.is_test_order,
    (p.is_deleted or o.is_deleted)                 as is_deleted,
    greatest(p.synced_at, o.synced_at)             as last_changed_at,
    current_timestamp()                            as dbt_loaded_at
from {{ ref('stg_shop__payments') }} p
join {{ ref('int_orders_fx') }} o
    on o.order_id = p.order_id
{% if is_incremental() %}
where greatest(p.synced_at, o.synced_at) >= {{ watermark() }}
{% endif %}
