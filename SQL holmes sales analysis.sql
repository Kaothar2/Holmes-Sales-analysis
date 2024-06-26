-- 1.Analyze Product Category Performance
--  a.Use SQL queries to determine the total revenue generated by each product category. 
   
select * from products;
select * from sales;
select * from customers;

select productname, category, sum (quantity * saleprice) as totalrevenue
from sales
join products
on sales.productid = products.productid
group by category

-- b.the top 3 customers by spending within each category 

select firstname, lastname, sum (quantity * saleprice) as totalspent
from sales s
join customers cu
on s.customerid= cu.customerid
group by firstname, lastname
order by totalspent desc
limit 3


---- 2.Customer Purchasing Patterns
---- a.Perform an analysis on customers whose names start with 'J' ' and have made purchases totaling over 
$1,000. 
-- This task involves joining sales data with customer information, which can help in understanding high
-- value customer behaviors and preferences.

select firstname, lastname , sum(quantity * saleprice) as totalspent
from customers cu
join sales s
on cu.customerid = s.customerid
where firstname like 'J%'
group by firstname, lastname
having sum(quantity * saleprice) > 1000
order by totalspent desc


-- 3. Inventory Management:
-- Identify products that have never been sold by using subqueries. 
-- This analysis is crucial for inventory management, 
-- helping to decide on discontinuing certain products or initiating promotional efforts to boost their sales

select distinct productid
from sales

select productid,productname, category, price
from products
where productid not in (select distinct productid
from sales
);	

select distinct (s.productid), productname,category, price
from products pr
left join sales s
on pr.productid = s.productid
where s.productid is null


-- 4. Sales Trend Analysis:
-- Analyze sales made in the first quarter and December, using UNION operations
-- This task will help in understanding seasonal trends and planning inventory
-- and marketing efforts accordingly.

select saleid, productid, customerid, saledate, quantity, saleprice
from sales
where extract(month from saledate) between 1 and 3

select saleid, productid, customerid, saledate, quantity, saleprice
from sales
where extract(year from saledate) = 2023
and extract(month from saledate) between 1 and 3

Union
-- sales in december
select saleid, productid, customerid, saledate, quantity, saleprice
from sales
-- where extract(year from saledate) = 2023
where extract(month from saledate) = 12


-- 5.Payment Method Insights:
-- Evaluate the average, minimum, and maximum sale amounts for each payment method
-- excluding sales below $50.
-- These insights can inform payment process improvements and promotional offers

select paymentmethod, avg (quantity * saleprice) as averagesaleamount,
min(quantity * saleprice) as minimumsaleamount,
max(quantity * saleprice) as maximumsaleamount
from sales
where quantity * saleprice >= 50
group by paymentmethod
order by paymentmethod


-- 6. Product Catalog Optimization:
-- Determine the number of unique product categories and 
-- identify products with the word 'smart' in their names.
-- This task can guide product development and marketing strategies, focusing on trending products and categories

select count(distinct category) as uniquecategories
from products

select productname
from products
where productname ilike '%smart%'


-- 7.Revenue Generation Analysis:
-- Create a view showing total sales and revenue generated by each product
-- then select products that have generated significant revenue.
-- This analysis helps in identifying star products and optimizing the product mix

create view productsalessummary as
select s.productid,productname, count(saleid) as totalsales,
sum(quantity * saleprice) as totalrevenue
from sales s
join products pr
on s.productid = pr.productid
group by s.productid, productname;

select productid, productname , totalsales, totalrevenue
from productsalessummary
where totalrevenue > 10000


-- 8.Stock Level Adjustment
-- Develop a stored procedure for updating stock levels by product category
-- This automated task will improve stock management efficiency, ensuring optimal inventory levels based on sales data

create or replace procedure update_stock_level(category_name VARCHAR, stock_increment INT)
Language plpgsql
as $$
begin update products
set stockquantity = stockquantity + stock_increment
where category = category_name;
end;
$$

call update_stock_level ('Electronics',10);

select * from products
where category = 'Electronics';

create or replace procedure update_stock_level_product(product_name VARCHAR, stock_increment INT)
Language plpgsql
as $$
begin update products
set stockquantity = stockquantity + stock_increment
where productname = product_name;
end;
$$

call update_stock_level_product('Coffee Maker', -30);

select * from products
where productname = 'Coffee Maker' ;


-- 9.Customer Spending Ranking:
-- Use window functions to rank customers based on their total spending and 
-- calculate cumulative revenue per product category over time. 
-- These tasks are vital for customer segmentation and targeted marketing campaigns

select s.customerid,firstname,lastname , sum(quantity * saleprice) as totalspending,
rank() over(order by sum(quantity *saleprice) desc) as spendingrank
from customers cu
join sales s
on cu.customerid = s.customerid
group by s.customerid, firstname, lastname
order by totalspending desc;


-- 10.Sales Performance Categorization:
-- Categorize each sale into 'Low', 'Medium', and 'High' intensity 
-- based on the total sale amount using CASE statements. 
-- This analysis will help in identifying sales patterns and adjusting sales strategies accordingly.

select category , saledate,
sum (quantity * saleprice) over(partition by category order by saledate) as cumulativerevenue
from sales s
join products pr
on s.productid = pr.productid
order by category, saledate desc
