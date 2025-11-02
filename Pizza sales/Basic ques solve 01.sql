create database pizzahut;
use pizzahut;

-- create table orders(
-- 	order_id int primary key,
--     order_date date not null,
--     order_time time not null
-- );

-- create table orders_details(
-- 	order_details_id int not null,
--     order_id int not null,
--     pizza_id text not null,
--     quantity int not null,
--     primary key(order_details_id)
-- );



-- Retrive the total number of order
-- select count(order_id) as total_orders from orders;



-- Total revenue genarated from pizza sales
-- select round(sum(orders_details.quantity * pizzas.price),3) as Total_sales
-- from orders_details join pizzas on pizzas.pizza_id = orders_details.pizza_id;


--  Highest Price Pizza
-- select pizza_types.name, pizzas.price from pizza_types join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id order by pizzas.price desc limit 1;


-- Identify the most common pizza size ordered.
-- select quantity, count(order_details_id)
-- from orders_details group by quantity;

-- select pizzas.size, count(orders_details.order_details_id) as order_count 
-- from pizzas join orders_details on pizzas.pizza_id= orders_details.pizza_id group by pizzas.size order by order_count desc;


-- List the top 5 most ordered pizza types along with their quantities.
-- select pizza_types.name, sum(orders_details.quantity) as quantity
-- from pizza_types join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id
-- join orders_details  on orders_details.pizza_id= pizzas.pizza_id group by pizza_types.name order by quantity desc limit 5;


