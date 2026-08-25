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
    inner join {{ ref('vehicle_dol') }}  veh --using an inner join here because a sale is only valid if we know the vehicle sold
        on sale.vehicle_id = veh.vehicle_id
        and sale.sale_id = veh.sale_id
    left join {{ ref('stg_dealerships') }}  dlrshp  --left joining here because we don't want to lose visibility on a sale if the dealership id is missing
        on veh.dealership_id = dlrshp.dealership_id


        