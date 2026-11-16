{# Calendar with a fiscal year that starts in var('fiscal_year_start_month').
   Shifting each date forward by (13 - start) mod 12 months makes the calendar year
   of the shifted date equal to the fiscal year (named by the year it ends in). #}
with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('start_date') ~ "' as date)",
        end_date="dateadd(year, 2, current_date)"
    ) }}
),

shifted as (
    select
        cast(date_day as date) as date_day,
        dateadd(month, mod(13 - {{ var('fiscal_year_start_month') }}, 12), cast(date_day as date)) as fy_shifted
    from spine
)

select
    date_day,
    year(date_day)                       as calendar_year,
    quarter(date_day)                    as calendar_quarter,
    month(date_day)                      as month_number,
    monthname(date_day)                  as month_name,
    date_trunc('month', date_day)::date  as month_start,
    date_trunc('week', date_day)::date   as week_start,
    dayname(date_day)                    as day_name,
    dayofweekiso(date_day) in (6, 7)     as is_weekend,
    year(fy_shifted)                     as fiscal_year,
    quarter(fy_shifted)                  as fiscal_quarter
from shifted