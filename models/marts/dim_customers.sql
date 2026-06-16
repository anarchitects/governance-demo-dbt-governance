with customers as (
  select *
  from {{ ref('stg_customers') }}
),
orders as (
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
  c.customer_id,
  c.customer_name,
  c.email,
  r.first_order_date,
  r.most_recent_order_date,
  coalesce(r.order_count, 0) as order_count
from customers c
left join order_rollup r
  on c.customer_id = r.customer_id
