with latest as (
    select * from {{ source('shop', 'customers') }}
    qualify row_number() over (partition by id order by _fivetran_synced desc) = 1
)

select
    id::number                         as customer_id,
    lower(trim(email))                 as email,            -- PII: never exposed beyond staging
    initcap(trim(first_name))          as first_name,
    initcap(trim(last_name))           as last_name,
    upper(trim(country))               as country,
    trim(state)                        as state,
    trim(city)                         as city,
    coalesce(marketing_opt_in, false)  as marketing_opt_in,
    {{ utc_ntz('created_at') }}        as created_at,
    coalesce(_fivetran_deleted, false) as is_deleted,
    _fivetran_synced                   as synced_at
from latest
