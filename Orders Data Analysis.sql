use testdb;
SELECT * FROM df_orders;

-- Q1: find top 10 highest revenue generating products
select product_id, sum(sale_price) as sale
from df_orders
group by product_id 
order by sale  desc
limit 10;

-- Q2: Top 5 highest selling products in each region
select distinct region 
from df_orders; 
select region, product_id, sum(sale_price) as sale
from df_orders
group by region, product_id 
order by region, sale  desc;

-- I need total 20 regions, 5 regions for each products. I have to generate a rank.
with cte as (
select region, product_id, sum(sale_price) as sale
from df_orders
group by region, product_id)
select * from (
select *,
row_number() over (partition by region order by sale desc) as rn
from cte) rn
where rn <=5; # top 5 for each region

-- Q3: find month over month growth comparison for 2022 and 2023 sale (eg: jan 2022 vs jan 2023)

with cte as 
(select year (order_date) as order_year, 
		month(order_date) as order_month, 
        sum(sale_price) as sale 
from df_orders
group by year (order_date), month(order_date)
-- order by year (order_date), month(order_date)
)
select order_month
, sum(case when order_year=2022 then sale else 0 end) as sales_2022
, sum(case when order_year=2023 then sale else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- Q4: For each catagory which month had highest sales
with cte as (SELECT 
  Category,DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
  sum(sale_price) as sales
FROM df_orders
group by category, DATE_FORMAT(order_date, '%Y%m')
order by category, DATE_FORMAT(order_date, '%Y%m')
)
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
)a
where rn=1;

-- Q5: which sub category had highest growth by profit in 2023 compare to 2022
with cte as 
(select sub_category, year (order_date) as order_year, 
        sum(sale_price) as sale 
from df_orders
group by sub_category, year(order_date)
-- order by year (order_date), month(order_date)
)
, cte2 as(
select sub_category
, sum(case when order_year=2022 then sale else 0 end) as sales_2022
, sum(case when order_year=2023 then sale else 0 end) as sales_2023
from cte
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022 as highest_growth
from cte2
order by highest_growth desc
limit 1






