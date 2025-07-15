--select * from gold.report_customers;
create view gold.product_report as 
with basic_info as (select
s.product_key,
s.customer_key,
s.order_number,
s.order_date,
s.sales_amount,
s.quantity,
s.price,
p.product_name,
p.category,
p.subcategory,
p.cost,
p.product_line
from
gold.fact_sales s
left join gold.dim_products p
on p.product_key=s.product_key
where order_date is not null),

aggregate_info_prod as (
select
product_key,
count(distinct(customer_key)) as total_customers,
max(order_date) as latest_date,
product_name,
category,
subcategory,
count(distinct(order_number)) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity_sold,
DATEDIFF(month, min(order_date), max(order_date)) as life_span_of_prod_demand,
round(cast((sum(sales_amount)/sum(quantity)) as float), 2) as avg_selling_price
from
basic_info
group by product_key,
product_name,
category,
subcategory)

select
product_key,
product_name,
category,
subcategory,
total_customers,
total_orders,
total_sales,
total_quantity_sold,
life_span_of_prod_demand,
DATEDIFF(month, life_span_of_prod_demand, GETDATE()) as recency_of_sale,
case when total_orders=0 then total_sales
	else (total_sales/total_orders) 
end avg_order_revenue,
case when life_span_of_prod_demand=0 then total_sales
	else (total_sales/life_span_of_prod_demand)
end avg_monthly_revenue,
case when total_sales<60000 then 'LOW-PERFORMANCE'
	WHEN total_sales between 60000 and 150000 then 'MID-RANGE'
	ELSE 'HIGH-PERFORMANCE'
END performance_segment
from
aggregate_info_prod;
