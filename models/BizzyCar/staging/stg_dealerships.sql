select
    dealership_id,
    name as dealership_name,
    region
from {{ ref('dealerships') }}