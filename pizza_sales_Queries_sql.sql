Use pizzahut;

-- Query 1: Retrieve the total number of orders placed.
SELECT COUNT(order_id) as total_orders FROM ORDERS;

-- Query 2: Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(o2.quantity * p1.price), 2) AS total_sales FROM order_details o2
JOIN pizzas p1 ON p1.pizza_id = o2.pizza_id

-- Query 3: Identify the highest-priced pizza.
SELECT p2.name, p1.price AS highest_priced_pizza
FROM pizza_types p2
JOIN pizzas p1 ON p2.pizza_type_id = p1.pizza_type_id
ORDER BY highest_priced_pizza DESC LIMIT 1;

-- Query 4: Identify the most common pizza size ordered.
SELECT  p1.size, COUNT(o2.order_details_id) AS order_count
FROM pizzas p1
JOIN order_details o2 ON p1.pizza_id = o2.pizza_id
GROUP BY p1.size ORDER BY order_count DESC LIMIT 1;

-- Query 5: List the top 5 most ordered pizza types along with their quantities.
SELECT p2.name, SUM(o2.quantity) AS Total_qty
FROM pizza_types p2
JOIN pizzas p1 ON p2.pizza_type_id = p1.pizza_type_id
JOIN order_details o2 ON o2.pizza_id = p1.pizza_id
GROUP BY p2.name
ORDER BY Total_qty DESC LIMIT 5;

-- Query 6: Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM orders GROUP BY HOUR(order_time);

-- Query 7: Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) as total_count
FROM pizza_types GROUP BY category;

-- Query 8: Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT p2.category, SUM(o2.quantity) AS Total_qty FROM pizza_types p2
JOIN pizzas p1 ON p2.pizza_type_id = p1.pizza_type_id
JOIN order_details o2 ON o2.pizza_id = p1.pizza_id
GROUP BY p2.category ORDER BY Total_qty DESC;

-- Query 9: Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 0)
FROM (SELECT o1.order_date, SUM(o2.quantity) AS quantity FROM orders o1
    JOIN order_details o2 ON o1.order_id = o2.order_id GROUP BY o1.order_date) AS order_quantity;

-- Query 10: Determine the top 3 most ordered pizza types based on revenue.
SELECT p2.name, SUM(o2.quantity * p1.price) AS revenue FROM pizza_types p2
JOIN pizzas p1 ON p1.pizza_type_id = p2.pizza_type_id
JOIN order_details o2 ON o2.pizza_id = p1.pizza_id
GROUP BY p2.name ORDER BY revenue DESC LIMIT 3;

-- Query 11: Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date) as cum_revenue
from (SELECT o1.order_date, sum(o2.quantity*p1.price) as revenue
from order_details o2
JOIN pizzas p1 ON o2.pizza_id=p1.pizza_id
JOIN orders o1 ON o1.order_id=o2.order_id
group by o1.order_date) as sales;

-- Query 12: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, 
rank() over (partition by category order by revenue desc) as rn from
(SELECT p2.category, p2.name, sum(o2.quantity*p1.price) as revenue
from pizza_types p2
JOIN pizzas p1
ON p2.pizza_type_id=p1.pizza_type_id
JOIN order_details o2
ON o2.pizza_id=p1.pizza_id
group by p2.category, p2.name) as a) as b
where rn <= 3;

-- Query 13: Calculate the percentage contribution of each pizza type to total revenue.
SELECT p2.category,
Round(sum(o2.quantity*p1.price)/ (select Round(sum(o2.quantity*p1.price),2) as total_sales
from order_details o2
JOIN pizzas p1 ON p1.pizza_id= o2.pizza_id)*100,2) as revenue
from pizza_types p2
JOIN pizzas p1 ON p2.pizza_type_id=p1.pizza_type_id
JOIN order_details o2 ON o2.pizza_id=p1.pizza_id
group by p2.category order by revenue desc;
