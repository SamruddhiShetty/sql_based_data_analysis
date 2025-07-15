USE DataWarehouseAnalytics;

select year(order_date) as order_year,
month(order_date) as order_month, 
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales 
where order_date is not null 
group by year(order_date) , month(order_date)
order by year(order_date) , month(order_date);

select datetrunc(year, order_date) as orderYear,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by datetrunc(year, order_date)
order by datetrunc(year, order_date);

select format(order_date, 'yyyy-MMM') as orderYear,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by format(order_date, 'yyyy-MMM')
order by format(order_date, 'yyyy-MMM');
