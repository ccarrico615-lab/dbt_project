SELECT
    sale.sale_id,
    sale.vehicle_id,   

    veh.make,
    veh.model,
    veh.year,
    veh.vin,
    veh.mileage,

    sale.price,
    sale.total_sale,
    sale.discount,

    sale.date_sold,
    veh.date_listed,
    veh.days_on_lot,

    dlrshp.dealership_id,
    dlrshp.dealership_name,
    dlrshp.region

from
    {{ ref('sale_calcs') }}  sale
    inner join {{ ref('vehicle_dol') }}  veh
        on sale.vehicle_id = veh.vehicle_id
    inner join {{ ref('stg_dealerships') }}  dlrshp
        on veh.dealership_id = dlrshp.dealership_id


        