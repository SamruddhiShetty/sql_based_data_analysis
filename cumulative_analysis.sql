select
order_date,
total_sales,
SUM(total_sales) OVER (partition by order_date order by order_date) as running_total_sales
from(
select 
DATETRUNC(MONTH, order_date) as order_date, 
SUM(sales_amount) AS total_sales
from gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH, order_date)
)t

select
order_date,
total_sales,
SUM(total_sales) OVER (order by order_date) as running_total_sales,
avg_price,
AVG(avg_price) over (order by order_date) as moving_average_price
from(
select 
DATETRUNC(MONTH, order_date) as order_date, 
SUM(sales_amount) AS total_sales,
AVG(price) as avg_price
from gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH, order_date)
)t
