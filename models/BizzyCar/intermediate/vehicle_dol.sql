SELECT
    veh.vehicle_id,
    veh.make,
    veh.model,
    veh.year,
    veh.vin,
    veh.mileage,
    veh.dealership_id,
    veh.date_listed,
    sale.date_sold - veh.date_listed as days_on_lot
FROM
    {{ ref('stg_vehicle') }} veh
    left join {{ ref('stg_sales') }} sale
        on veh.vehicle_id = sale.vehicle_id
