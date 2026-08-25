SELECT    
    veh.vehicle_id,
    sale.sale_id, --it's possible one of these vehicles could sell multiple times. Pull this in to join on later
    case when sale.sale_id is null then 'Available' else 'Sold' end as sale_status,
    veh.make,
    veh.model,
    veh.year,
    veh.vin,
    veh.mileage,
    veh.date_listed,
    -- grab the difference between date_listed and current date in case user wants to see how long the car has been sitting unsold
    -- it does mean this value will change depending on when the model is run. I would typically base this on some sort of snapshot date instead of "current_date"
    date_diff(coalesce(sale.date_sold,current_date), veh.date_listed, day) as days_on_lot, 
    veh.dealership_id
FROM
    {{ ref('stg_vehicle') }} veh
    left join {{ ref('stg_sales') }} sale
        on veh.vehicle_id = sale.vehicle_id
