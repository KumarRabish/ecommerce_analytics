-- Row-count reconciliation against RAW, applying the same delete rules.
with raw as (
    select count(*) as n
    from {{ source('shop', 'order_items') }} i
    join {{ source('shop', 'orders') }} o on o.id = i.order_id
    where not coalesce(i._fivetran_deleted, false)
      and not coalesce(o._fivetran_deleted, false)
),
mart as (
    select count(*) as n from {{ ref('fct_order_items') }} where not is_deleted
)
select raw.n as raw_rows, mart.n as mart_rows
from raw cross join mart
where raw.n <> mart.n
