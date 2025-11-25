use sales;


-- Calculate the moving average of order values for each customer over their order history
select customer_id, order_purchase_timestamp, payment,
avg(payment) over(partition by customer_id order by order_purchase_timestamp
rows between 3 preceding and current row) as mov_avg
from
(select orders.customer_id, orders.order_purchase_timestamp, 
payments.payment_value as payment
from payments join orders
on payments.order_id = orders.order_id) as a;




-- Calculate the cumulative sales per month for each year
SELECT years, months, payment, SUM(payment) OVER (ORDER BY years, months) AS cumulative_sales
FROM (SELECT YEAR(orders.order_purchase_timestamp) AS years, MONTH(orders.order_purchase_timestamp) AS months, 
ROUND(SUM(payments.payment_value),2) AS payment
FROM orders JOIN payments ON orders.order_id = payments.order_id
GROUP BY YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)) AS a
ORDER BY years, months;




--Calculate the year-over-year growth rate of total sales.
SELECT year,
       total_sales,(total_sales - LAG(total_sales) OVER(ORDER BY year)) 
        / LAG(total_sales) OVER(ORDER BY year) * 100  AS yoy_growth_rate
FROM (SELECT YEAR(order_purchase_timestamp) AS year, SUM(oi.price) AS total_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(order_purchase_timestamp)) AS t;






--Calculate the retention rate of customers, defined as the percentage of customers who make another purchase within 6 months of their first purchase
SELECT (COUNT(*) * 1.0 / (SELECT COUNT(DISTINCT customer_id) FROM orders)) * 100 AS retention_rate
FROM (SELECT o1.customer_id
    FROM orders AS o1
    JOIN orders AS o2
        ON o1.customer_id = o2.customer_id
       AND o2.order_purchase_timestamp > o1.order_purchase_timestamp
       AND o2.order_purchase_timestamp <= DATEADD(MONTH, 6, o1.order_purchase_timestamp)
    GROUP BY o1.customer_id
) AS t;




--Identify the top 3 customers who spent the most money in each year.
SELECT *
FROM (
    SELECT YEAR(o.order_purchase_timestamp) AS year,
           o.customer_id,
           SUM(oi.price) AS total_spent,
           RANK() OVER (PARTITION BY YEAR(o.order_purchase_timestamp)
                        ORDER BY SUM(oi.price) DESC) AS rank_num
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_purchase_timestamp), o.customer_id
) t
WHERE rank_num <= 3;

