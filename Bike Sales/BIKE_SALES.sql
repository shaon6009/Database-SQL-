use BikeStores;

select * from production.brands;
select * from production.categories;
select * from production.products;
select * from production.stocks;
select * from sales.customers;
select * from sales.order_items;
select * from sales.orders;
select * from sales.staffs;
select * from sales.stores;

-- List all products including their name and list price, sorted by price from highest to lowest.
select product_name, list_price from production.products order by list_price desc;

-- Find all customers who live in the city of 'New York'.
select * from sales.customers where city= 'new York';

--List all unique states where the bike stores are located.
select distinct state from sales.stores;

--Find all orders that have not been shipped yet (where the shipped date is missing).
select * from sales.orders where shipped_date is NULL and staff_id=9;

-- How many staff members are currently marked as "active" (active = 1)?
select count(*) as Active_Staffs from sales.staffs where active= 1;
select first_name from sales.staffs where active= 1;





-- List every product name alongside its associated brand name.
select p.product_name , b.brand_name from production.products as p 
join production.brands as b on p.brand_id= b.brand_id;

-- Find the total number of products in each category. Display category name and the count.
select c.category_name, count(p.product_id) as Product_count 
from production.categories as c join production.products as p 
on c.category_id= p. category_id group by c.category_name;


-- List all order IDs and the full name (first and last) of the customer who placed them.
SELECT o.order_id, c.first_name + ' ' + c.last_name AS customer_name
FROM sales.orders as o JOIN sales.customers as c ON o.customer_id = c.customer_id;


-- Find the total number of orders placed in the year 2016.
select count(order_id) as Total_Order_2016
from sales.orders where order_date between '2016-01-01' and '2016-12-31';

-- List all categories that have more than 10 products assigned to them.
SELECT c.category_name, COUNT(p.product_id)
FROM production.categories c
join production.products p ON c.category_id = p.category_id
group by  c.category_name having COUNT(p.product_id) > 10;






-- Find the names of products that have never been ordered.
select product_name from production.products 
where product_id not in (select product_id from sales.order_items);

-- List the name of every staff member and the name of their manager (Self-Join).
select s.first_name as Staff_name, m.first_name as manager_name
from sales.staffs as s left join sales.staffs as m on s.manager_id= m.staff_id;

-- Calculate the total revenue (Quantity * Price * (1 - Discount)) for order ID 1.
SELECT SUM(quantity * list_price * (1 - discount)) AS total_revenue
FROM sales.order_items
WHERE order_id = 1;

-- List products that have a list price higher than the average price of all products.
SELECT product_name, list_price FROM production.products
WHERE list_price > (SELECT AVG(list_price) FROM production.products);

-- Display store names and the total quantity of stock they have across all products.
select s.store_name , sum(st.quantity) as Total_stock 
from sales.stores as s 
join production.stocks as st on s.store_id= st.store_id group by s.store_name






-- Rank products by their list price within each category using a window function.
SELECT category_id, product_name, list_price,
RANK() OVER(PARTITION BY category_id ORDER BY list_price DESC) as price_rank
FROM production.products;

-- For all orders in 2017, show the order date and a running total of orders placed up to that date.
select order_date, count(order_id) over(order by order_date) as Running_Total_Orders
from sales.orders where order_date like '2017%';

-- Use a CTE (Common Table Expression) to find the top 3 customers by total money spent.
WITH CustomerSpend AS (
SELECT c.customer_id, c.first_name, c.last_name,
SUM(oi.list_price * oi.quantity * (1 - oi.discount)) as total_spent FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT TOP 3 * FROM CustomerSpend order by total_spent DESC;

-- List each store and the count of orders grouped by status (1 = Pending, 4 = Completed).
select store_id,
sum(case when order_status=1 then 1 else 0 end) as Pending_Orders,
sum(case when order_status=4 then 1 else 0 end) as Compleate_Orders
from sales.orders group by store_id;

-- Find the most expensive product in every brand using ROW_NUMBER()
SELECT brand_name, product_name, list_price
FROM (SELECT b.brand_name, p.product_name, p.list_price,
ROW_NUMBER() OVER(PARTITION BY b.brand_id ORDER BY p.list_price DESC) as rn
FROM production.brands b JOIN production.products p ON b.brand_id = p.brand_id
) t WHERE rn = 1;

