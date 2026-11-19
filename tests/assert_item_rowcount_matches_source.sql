
-- tests/assert_item_rowcount_matches_source.sql

with raw as (

    select
        i.id as order_item_id,
        count(*) as row_count
    from {{ source('shop', 'order_items') }} i
    join {{ source('shop', 'orders') }} o
        on o.id = i.order_id
    where not coalesce(i._fivetran_deleted, false)
      and not coalesce(o._fivetran_deleted, false)
    group by i.id

),

mart as (

    select
        order_item_id,
        count(*) as row_count
    from {{ ref('fct_order_items') }}
    where not coalesce(is_deleted, false)
    group by order_item_id

),

comparison as (

    select
        coalesce(r.order_item_id, m.order_item_id) as order_item_id,
        coalesce(r.row_count, 0) as raw_count,
        coalesce(m.row_count, 0) as mart_count
    from raw r
    full outer join mart m
        on r.order_item_id = m.order_item_id

)

select *
from comparison
where raw_count <> mart_count
