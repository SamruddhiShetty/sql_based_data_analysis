--use DataWarehouseAnalytics;

create view gold.report_customers as
-- base query: retrieve core columns from tables
with base_query as (select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
from
gold.fact_sales f
left join gold.dim_customers c
on f.customer_key= c.customer_key
where f.order_date is not null),

--customer aggregation: summarizes key metrics at the customer level
cust_aggregate_info as (select
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT(order_number)) as total_orders,
COUNT(DISTINCT(product_key)) as total_products,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
max(order_date) as last_order_dt,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as life_span_cust
from
base_query
group by customer_key,
customer_number,
customer_name,
age)

-- for the final results
select
customer_key,
customer_number,
customer_name,
age,
case when age<20 then 'Under 20'
	when age between 20 and 29 then '20-29'
	when age between 20 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	else '50 and above'
end age_catgeory,
case when life_span_cust>=12 and total_sales>5000 THEN 'VIP'
	when life_span_cust>=12 and total_sales<=5000 THEN 'REGULAR'
	ELSE 'NEW'
end customer_segment,
DATEDIFF(year, last_order_dt, GETDATE()) AS recency_of_order,
total_orders,
total_products,
total_sales,
total_quantity,
last_order_dt,
life_span_cust,
(total_sales/total_orders) as avg_order_value, 
case when life_span_cust=0 THEN total_sales
	else (total_sales/(life_span_cust))
end avg_monthly_spent
from cust_aggregate_info
;

