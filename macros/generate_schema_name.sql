{# In prod use the custom schema as-is (staging, marts, semantic).
   In dev/ci prefix with the developer or PR schema so nobody overwrites production. #}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- set invocation_context = env_var('DBT_CLOUD_INVOCATION_CONTEXT', '') -%}

    {%- if custom_schema_name is none -%}
<<<<<<< HEAD
        {{ default_schema }}

    {%- elif invocation_context == 'prod' -%}
        {{ custom_schema_name | trim }}

    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}

=======
        {{ target.schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}_{{ custom_schema_name | trim }}
>>>>>>> bc943ceac130bd6fdb50d272d6b7955efeade81b
    {%- endif -%}

{%- endmacro %}

