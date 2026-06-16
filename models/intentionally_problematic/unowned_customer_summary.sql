select
  case
    when order_count = 0 then 'no_orders'
    when order_count between 1 and 2 then 'repeatable'
    else 'high_value'
  end as customer_segment,
  count(*) as customer_count
from {{ ref('dim_customers') }}
group by 1
