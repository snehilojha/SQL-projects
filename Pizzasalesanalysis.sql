--Retrieve the total number of orders placed.

SELECT DISTINCT COUNT(order_id) AS Total_no_of_orders
FROM PIZZA..orders

--Calculate the total revenue generated from pizza sales.
SELECT round(sum(p.price * od.quantity),2) as total_sales
FROM PIZZA..pizzas	p
JOIN PIZZA..order_details od 
	ON p.pizza_id = od.pizza_id

--Identify the highest-priced pizza.
SELECT TOP 1 pt.name,p.size, price
FROM PIZZA..pizzas p
JOIN PIZZA..pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
order by 3 desc 

--Identify the most common pizza size ordered.
SELECT p.size, sum(quantity) as order_count
FROM PIZZA..pizzas	p
JOIN order_details od
	ON p.pizza_id = od.pizza_id
group by p.size

--List the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5 pt.Name , sum(quantity) as Total_quantities
FROM PIZZA..pizzas	p
JOIN pizza_types pt
	ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
	ON p.pizza_id = od.pizza_id
group by pt.name
order by Total_quantities desc

--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category , sum(quantity) as Total_quantities
FROM PIZZA..pizzas	p
JOIN pizza_types pt
	ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
	ON p.pizza_id = od.pizza_id
group by pt.category
order by Total_quantities desc

--Determine the distribution of orders by hour of the day.
SELECT DATENAME(HOUR,Time) Hour, COUNT(o.order_id) orders
FROM orders o
JOIN order_details od
	on o.order_id = od.order_id
group by DATENAME(HOUR,Time)
order by orders desc

--Join relevant tables to find the category-wise distribution of pizzas.
SELECT Category, count(category) Available_options
FROM PIZZA..pizza_types
group by category

--Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT avg(qty) as Avg_pizza_ordered_perday FROM 
(SELECT o.date , sum(od.quantity) qty
FROM orders o
JOIN order_details od
	ON o.order_id = od.order_id
GROUP BY o.date) as order_quantity

--Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3 pt.name , sum(p.price * od.quantity) as Total_revenue
FROM pizzas p
JOIN pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
	on p.pizza_id = od.pizza_id
group by pt.name
order by Total_revenue desc

--Calculate the percentage contribution of each pizza category to total revenue.
SELECT pt.Category , round(sum(p.price * od.quantity) / (SELECT sum(p.price * od.quantity) as total_sales
FROM PIZZA..pizzas	p
JOIN PIZZA..order_details od 
	ON p.pizza_id = od.pizza_id) * 100,2) as Revenue
FROM pizzas p
JOIN pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
	on p.pizza_id = od.pizza_id
group by pt.category
order by revenue desc

--Analyze the cumulative revenue generated over time.

SELECT *
FROM orders
SELECT *
FROM order_details
SELECT *
FROM pizzas

SELECT date, sum(revenue) over(order by date) as cum_revenue
FROM
(SELECT o.date , sum(od.quantity*p.price) as revenue
FROM order_details od
JOIN orders o
	ON o.order_id = od.order_id
JOIN pizzas p
	ON od.pizza_id = p.pizza_id
GROUP BY o.date) as sales

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT Category, Name, Revenue
FROM
(SELECT Category , Name, Revenue, rank() 
OVER (PARTITION BY Category ORDER BY revenue DESC) as Rank
FROM
(SELECT pt.category, pt.name, sum(od.quantity*p.price) as revenue
FROM pizza_types pt
JOIN pizzas p
	ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
	ON od.pizza_id = p.pizza_id
GROUP BY pt.category, pt.name) a) b
WHERE Rank <= 3
