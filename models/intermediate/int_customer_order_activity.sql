with orders as (
  select *
  from {{ ref('stg_orders') }}
),
order_rollup as (
  select
    customer_id,
    min(order_date) as first_order_date,
    max(order_date) as most_recent_order_date,
    count(*) as order_count
  from orders
  group by customer_id
)

select
  customer_id,
  first_order_date,
  most_recent_order_date,
  order_count
from order_rollup
