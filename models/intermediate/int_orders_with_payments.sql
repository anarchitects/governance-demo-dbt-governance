with orders as (
  select *
  from {{ ref('stg_orders') }}
),
payments as (
  select *
  from {{ ref('stg_payments') }}
)

select
  o.order_id,
  o.customer_id,
  o.order_date,
  o.status,
  p.amount,
  p.payment_method
from orders o
left join payments p
  on o.order_id = p.order_id
