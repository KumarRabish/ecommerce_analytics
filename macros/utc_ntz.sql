{# Convert any timestamp to UTC wall-clock time. One clock for the whole warehouse. #}
{% macro utc_ntz(column) -%}
    convert_timezone('UTC', {{ column }})::timestamp_ntz
{%- endmacro %}
