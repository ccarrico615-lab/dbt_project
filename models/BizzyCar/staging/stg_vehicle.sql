select
    vehicle_id,
    make,
    model,
    year,
    vin,
    mileage,
    dealership_id,
    date_listed
from {{ ref('vehicle') }}