/* Question Set 1 - Easy */

/* Q1. Retrieve the total number of orders placed. */

SELECT COUNT(order_id) as Total_Orders 
FROM orders;

/* Q2. Calculate the total revenue generated from pizza sales. */

SELECT SUM(order_details.quantity * pizzas.price) as Total_Sales
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

/* Q3. Identify the highest-priced pizza. */

SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC 
LIMIT 1;

/* Q4. Identify the most common pizza size ordered. */

SELECT pizzas.size, COUNT(order_details.order_details_id) as Order_Count
FROM pizzas 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;

/* Q5. List the top 5 most ordered pizza types along with their quantities. */

SELECT pizza_types.name, SUM(order_details.quantity) as Quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;



/* Question Set 2 - Intermediate */

/* Q1. Join the necessary tables to find the total quantity of each pizza category ordered. */

SELECT pizza_types.category, SUM(order_details.quantity) AS Quantity
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

/* Q2. Determine the distribution of orders by hour of the day. */

SELECT EXTRACT(HOUR FROM order_time) AS order_hour, COUNT(order_id) as order_count
FROM orders
GROUP BY order_hour; 

/* Q3. Join relevant tables to find the category-wise distribution of pizzas. */

SELECT category, COUNT(name) 
FROM pizza_types
GROUP BY category;

/* Q4. Group the orders by date and calculate the average number of pizzas ordered per day. */

SELECT ROUND(AVG(quantity), 2) AS avg_pizza_ordered_per_day 
FROM (
       SELECT orders.order_date, SUM(order_details.quantity) as quantity
       FROM orders
       JOIN order_details ON orders.order_id = order_details.order_id
       GROUP BY orders.order_date
);

/* Q5. Determine the top 3 most ordered pizza types based on revenue. */

SELECT pizza_types.name, SUM(order_details.quantity * pizzas.price) as revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



/* Question Set 3 - Advanced */

/* Q1. Calculate the percentage contribution of each pizza type to total revenue. */

SELECT pizza_types.category, ROUND((SUM(order_details.quantity * pizzas.price)/(817860.05)) * 100, 2) as total_revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_revenue DESC;

/* Q2. Analyze the cumulative revenue generated over time. */ 

SELECT order_date, SUM(total_revenue) OVER(ORDER BY order_date) as cum_revenue 
FROM (
      SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) as total_revenue
      FROM order_details
      JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
      JOIN orders ON orders.order_id = order_details.order_id
      GROUP BY orders.order_date
	  ) as daily_sales
;

/* Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category. */

WITH cte AS (SELECT category, name, total_revenue, RANK()OVER(PARTITION BY category ORDER BY total_revenue DESC) as rank_no
          FROM (
                SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity * pizzas.price) as total_revenue
                FROM pizza_types
                JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
                JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
                GROUP BY pizza_types.category, pizza_types.name
	           ) 
		    )   
SELECT category, name, total_revenue FROM cte
WHERE rank_no <= 3
;