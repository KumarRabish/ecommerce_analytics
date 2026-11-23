{# In prod use the custom schema as-is (staging, marts, semantic).
   In dev/ci prefix with the developer or PR schema so nobody overwrites production. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
<<<<<<< HEAD
    {# {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }} #}
=======
    {#{%- elif target.name == 'PROD' -%}
        {{ custom_schema_name | trim }}#}
>>>>>>> 4efe74a42dd7b263abed986e7a2464d2681329ea
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
