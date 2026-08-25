SELECT
    sale.sale_id,
    sale.vehicle_id,
    sale.price,
    sale.total_sale,
    sale.date_sold,
    --if the total_sale is greater than or equal to the price, we don't want to consider that a "discount"
    case when round(sale.price - sale.total_sale,2) <= 0 then NULL 
      else round(sale.price - sale.total_sale,2)
    end as discount
FROM
    {{ ref('stg_sales') }} sale
