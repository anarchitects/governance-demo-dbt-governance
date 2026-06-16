select *
from {{ ref('int_orders_with_payments') }}
