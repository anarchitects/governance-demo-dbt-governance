select
  o.order_id,
  o.customer_id,
  o.order_date,
  o.status,
  p.amount,
  p.payment_method
from {{ ref('stg_orders') }} o
left join {{ ref('stg_payments') }} p
  on o.order_id = p.order_id
