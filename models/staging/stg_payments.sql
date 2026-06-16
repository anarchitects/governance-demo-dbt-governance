select
  id as payment_id,
  order_id,
  cast(amount as double) as amount,
  payment_method
from {{ source('raw', 'raw_payments') }}
