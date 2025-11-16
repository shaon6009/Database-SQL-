use sales;

--1. List all unique cities where customers are located.
select * from customers;
select distinct customer_city from customers;




--2. Count the number of orders placed in 2017.
select *from Orders;
SELECT COUNT(*) AS order_places_in_2017 FROM orders WHERE YEAR(order_purchase_timestamp) = 2017;



-- 3. Find the total sales per category.
select * from products;
select * from order_items;
select products.product_category, sum(order_items.price) as total_sales
from order_items join products on order_items.product_id= products.product_id
group by products.product_category;



-- 4. Calculate the percentage of orders that were paid in installments.
select max(payment_installments) as Payment_installments from payments;
select min(payment_installments) as Payment_installments from payments;

SELECT 
    (100.0 *SUM(CASE WHEN payment_installments> 1 then 1 ELSE 0 END) / COUNT(*)) 
    AS payment_installment_percentage_orders
FROM payments;




-- 5Count the number of customers from each state.
select customer_state,  count(*) as customer_count from customers group by customer_state

-- Count the number of customers from each state and city.
select customer_state, customer_city, count(*) as customer_count 
from customers 
group by customer_state, customer_city ; --order by customer_state desc;

-- Count the number of customers from each city.
select customer_city , count(*) as customer_count_per_state 
from customers group by customer_city;