SELECT
    sale.sale_id,
    sale.vehicle_id,
    sale.price,
    sale.total_sale,
    sale.date_sold,
    case when round(sale.price - sale.total_sale,2) <= 0 then NULL 
      else round(sale.price - sale.total_sale,2)
    end as discount
FROM
    {{ ref('stg_sales') }} sale
