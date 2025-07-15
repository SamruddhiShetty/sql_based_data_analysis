--segment products into cost ranges and count how many products fall into each segment
with product_segments as (
select
product_key,
product_name,
cost,
CASE WHEN cost<100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 100'
END cost_range
from
gold.dim_products)

select 
cost_range,
COUNT(PRODUCT_KEY) AS total_products
from product_segments
GROUP BY cost_range
order by total_products desc;

select 
customer_key,
sales_amount, 
DATETRUNC(MONTH, order_date)
from gold.fact_sales;

------------
with customer_info as (SELECT
customer_key,
SUM(sales_amount) as total_spendings,
MAX(order_date) as end_date,
MIN(order_date) as first_date,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifeSpan_of_spending
FROM
GOLD.fact_sales
group by customer_key),

customer_segment_info as (select
customer_key,
total_spendings,
lifeSpan_of_spending,
case when lifeSpan_of_spending>=12 and total_spendings>5000 THEN 'VIP'
	when lifeSpan_of_spending>=12 and total_spendings<=5000 THEN 'REGULAR'
	ELSE 'NEW'
end customer_segment
from customer_info)

select
customer_segment,
count(customer_key) as Total_customers
from customer_segment_info
group by customer_segment
order by count(customer_key) desc;
