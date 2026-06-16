select
  id as customer_id,
  first_name,
  last_name,
  first_name || ' ' || last_name as customer_name,
  email,
  cast(created_at as date) as created_at
from {{ source('raw', 'raw_customers') }}
