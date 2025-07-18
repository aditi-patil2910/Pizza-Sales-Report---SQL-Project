-- Retrieve the total number of orders placed.

SELECT DISTINCT COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM ORDERS

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS TOTAL_REVENUE
FROM order_details 
JOIN pizzas 
ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.

SELECT name, price
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT name, SUM(quantity) as quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category, SUM(order_details.quantity) as quantity
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT hour(time) AS HOUR, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR ;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) AS pizza
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS avg_quantity FROM
(SELECT  orders.date, SUM(order_details.quantity) AS quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name, ROUND(SUM(order_details.quantity*pizzas.price),0) as revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON  order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category, ROUND((SUM(order_details.quantity*pizzas.price) /
(SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS TOTAL_REVENUE
FROM order_details 
JOIN pizzas 
ON pizzas.pizza_id = order_details.pizza_id )) * 100, 2) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY revenue DESC

-- Analyze the cumulative revenue generated over time.

SELECT date, 
sum(revenue) over(order by date) as cum_revenue
FROM
(SELECT orders.date, SUM(order_details.quantity*pizzas.price) as revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders 
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS Sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,name,revenue
FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC ) AS RN
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b
WHERE RN<=3;