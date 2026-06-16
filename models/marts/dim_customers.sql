select
  customer_id,
  first_order_date,
  most_recent_order_date,
  order_count
from {{ ref('int_customer_order_activity') }}
