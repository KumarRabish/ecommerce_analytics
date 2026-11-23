{# In prod use the custom schema as-is (staging, marts, semantic).
   In dev/ci prefix with the developer or PR schema so nobody overwrites production. #}


{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- set invocation_context = env_var('DBT_CLOUD_INVOCATION_CONTEXT', '') -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {%- elif invocation_context == 'prod' -%}
        {{ custom_schema_name | trim }}

    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}


