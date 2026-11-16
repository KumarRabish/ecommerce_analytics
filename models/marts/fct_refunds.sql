{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='refund_id',
    on_schema_change='append_new_columns'
) }}

select
    refund_id,
    order_id,
    order_item_id,
    refund_date,
    refunded_at,
    refund_reason,
    refund_amount_usd,
    is_test_order,
    is_deleted,
    last_changed_at,
    current_timestamp() as dbt_loaded_at
from {{ ref('int_refunds_enriched') }}
{% if is_incremental() %}
where last_changed_at >= {{ watermark() }}
{% endif %}
