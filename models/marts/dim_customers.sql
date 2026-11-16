with customers as (
    select * from {{ ref('stg_shop__customers') }} where not is_deleted
),

first_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        min(ordered_at) as first_order_at,
        count(*)        as lifetime_orders
    from {{ ref('int_orders_fx') }}
    where not is_deleted and not is_test_order and is_revenue_recognized
    group by 1
)

select
    c.customer_id                     as customer_key,
    c.country,
    c.state,
    c.city,
    c.marketing_opt_in,
    c.created_at                      as customer_created_at,
    f.first_order_date,
    f.first_order_at,
    coalesce(f.lifetime_orders, 0)    as lifetime_orders
from customers c
left join first_orders f on f.customer_id = c.customer_id

union all

-- unknown member: guest checkouts and orphan keys
select -1, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', false, null::timestamp_ntz, null::date, null::timestamp_ntz, 0
