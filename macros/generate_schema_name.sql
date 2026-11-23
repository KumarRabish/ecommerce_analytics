{# In prod use the custom schema as-is (staging, marts, semantic).
   In dev/ci prefix with the developer or PR schema so nobody overwrites production. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {# {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }} #}
    {%- else -%}
        {{ target.schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
