{% snapshot snap_customers %}
{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['country', 'state', 'city', 'marketing_opt_in']
    )
}}
select customer_id, country, state, city, marketing_opt_in
from {{ ref('stg_shop__customers') }}
where not is_deleted
{% endsnapshot %}
