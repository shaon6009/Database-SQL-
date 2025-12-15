use pizzahut;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    (SUM(orders_details.quantity * pizzas.price) / (SELECT 
            SUM(orders_details.quantity * pizzas.price) AS total_sales
        FROM
            orders_details
                JOIN
            pizzas ON pizzas.pizza_id = orders_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cumulative_revenue
from(select orders.order_date, sum(orders_details.quantity * pizzas.price) as revenue
from orders_details join pizzas on pizzas.pizza_id= orders_details.pizza_id
join orders on orders.order_id= orders_details.order_id
group by orders.order_date) as slaes;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, revenue
from(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn

from (select pizza_types.category, pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
FROM pizza_types JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <=3;
