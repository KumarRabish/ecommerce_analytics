{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='refund_id',
    on_schema_change='append_new_columns'
) }}

select
    cast(refund_id as number(38,0)) as refund_id,
    cast(order_id as number(38,0)) as order_id,
    order_item_id,
    refund_date,
    refunded_at,
    refund_reason,
    cast(refund_amount_usd as number(18,2)) as refund_amount_usd,
    is_test_order,
    is_deleted,
    last_changed_at,
    current_timestamp() as dbt_loaded_at
from {{ ref('int_refunds_enriched') }}
{% if is_incremental() %}
where last_changed_at >= {{ watermark() }}
{% endif %}
