select
    sale_id,
    vehicle_id,
    price,
    total_sale,
    date_sold
from {{ ref('sales') }}