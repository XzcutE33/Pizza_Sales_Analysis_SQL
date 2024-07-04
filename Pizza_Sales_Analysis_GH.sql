-- Creating a database named 'demo_pizza'. There are total 4 tables in this database, 
-- from which we can import data into 2 tables directly but for the remaining 2 tables data we have to create new tables.

CREATE DATABASE demo_pizza ;


CREATE TABLE order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);

SELECT * FROM pizza_sales.order_details;


CREATE TABLE orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
);

SELECT * FROM pizza_sales.orders;

-- I have answered some important questions by analyzing the data,
-- and hence giving you some results by which we can further take important decisions and can make effective strategies.


-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS 'Total_Orders'
FROM orders ;


-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price) , 2) AS 'Total_Revenue'
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id ;


-- Identify the highest-priced pizza.

SELECT pizza_types.name , pizzas.price
FROM pizzas JOIN pizza_types 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC 
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT pizzas.size , COUNT(order_details.pizza_id) AS 'order_count'
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizzas.size 
ORDER BY order_count DESC 
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name , SUM(order_details.quantity) AS 'total_quantity'
FROM order_details JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id 
JOIN pizza_types 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
GROUP BY pizza_types.name 
ORDER BY total_quantity DESC 
LIMIT 5;


-- Find the total quantity of each pizza category ordered.

SELECT pizza_types.category , SUM(order_details.quantity) AS 'total_quantity_ordered'
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category
ORDER BY total_quantity_ordered ;


-- Determine the distribution of orders by hour of the day.

SELECT  HOUR(orders.order_time) AS 'Hours' , COUNT(orders.order_id) AS 'order_count'
FROM orders
GROUP BY Hours 
ORDER BY order_count DESC;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(total_orders) , 0) AS average_orders_per_day
FROM 
(SELECT orders.order_date , SUM(order_details.quantity) AS total_orders
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id 
GROUP BY orders.order_date) AS total ;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name , SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.name 
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.category , 
ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT ROUND(SUM(order_details.quantity * pizzas.price) , 2)
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id) * 100 , 2) AS revenue

FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizza_types.category 
ORDER BY revenue DESC ;


-- Analyze the cumulative revenue generated over time.

SELECT order_date , total_revenue ,
ROUND(SUM(total_revenue) OVER (ORDER BY order_date) , 2) as cumm_revenue
FROM

(SELECT orders.order_date , ROUND(SUM(order_details.quantity * pizzas.price) , 2) as total_revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id 
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as total_sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category , name , total_revenue
FROM

(SELECT category , name , total_revenue,
RANK() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS Rankings
FROM
(SELECT pizza_types.category , pizza_types.name , 
SUM(order_details.quantity * pizzas.price) as total_revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.category , pizza_types.name) AS data) AS final_rank
WHERE Rankings <= 3 ;