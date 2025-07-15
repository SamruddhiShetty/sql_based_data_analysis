with yearly_product_sales as(

select 
year(f.order_date) as order_year,
d.product_name,
sum(f.sales_amount) as current_sales
from 
gold.fact_sales f
left join gold.dim_products d
on f.product_key = d.product_key
where f.order_date is not null
group by year(f.order_date), d.product_name
)

select
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) as avg_sales,
(current_sales-avg(current_sales) over (partition by product_name)) AS DIFF_IN_AVG,
CASE WHEN (current_sales-avg(current_sales) over (partition by product_name))>0 THEN 'ABOVE AVERAGE'
	WHEN (current_sales-avg(current_sales) over (partition by product_name))<0 THEN 'BELOW AVERAGE'
	ELSE 'AVG'
END avg_change,
lag(current_sales) over (partition by product_name order by order_year) as py_sales,
(current_sales - lag(current_sales) over (partition by product_name order by order_year)) as diff_in_salesPy,
CASE WHEN (current_sales-lag(current_sales) over (partition by product_name order by order_year))>0 THEN 'Increased'
	WHEN (current_sales-lag(current_sales) over (partition by product_name order by order_year))<0 THEN 'Decreased'
	ELSE 'Same'
END salesIndi
from
yearly_product_sales
order by product_name, order_year;
