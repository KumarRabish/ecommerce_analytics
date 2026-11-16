{# Appends a filter restricting a CTE to orders that changed since the watermark.
   Requires a CTE named changed_orders in the calling model. #}
{% macro changed_orders_filter(col='order_id') -%}
    {% if is_incremental() %}
        and {{ col }} in (select order_id from changed_orders)
    {% endif %}
{%- endmacro %}

{# Watermark = newest change already in the target minus the lookback window. #}
{% macro watermark(col='last_changed_at') -%}
    (select dateadd(hour, -{{ var('lookback_hours') }}, max({{ col }})) from {{ this }})
{%- endmacro %}
