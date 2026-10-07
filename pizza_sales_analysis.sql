-- 1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 0) 
AS total_sales
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- 3. Identify the highest-priced pizza.
SELECT pt.name AS name, MAX(p.price) AS max_price 
FROM pizza_types pt 
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY max_price DESC 
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT p.size, SUM(od.quantity)
AS total_pizzas_ordered
FROM pizzas p JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY SUM(od.quantity) DESC
LIMIT 1;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS total_orders
FROM pizzas p JOIN
order_details od ON
p.pizza_id = od.pizza_id JOIN
pizza_types pt ON
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_orders DESC
LIMIT 5;

-- 6. Total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity)
AS total_quantity_ordered
FROM pizzas p JOIN
order_details od ON
p.pizza_id = od.pizza_id JOIN
pizza_types pt ON
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity_ordered DESC;

-- 7. Distribution of orders by hour of the day. 
SELECT strftime('%H', o.time) AS hour, 
COUNT(o.order_id) AS orders_count 
FROM orders o
GROUP BY hour
ORDER BY hour;

-- 8. Category-wise distribution of pizzas.
SELECT pt.category,
COUNT(o.order_id) AS
orders_count FROM 
order_details od JOIN orders o ON 
od.order_id = o.order_id
JOIN pizzas p ON 
od.pizza_id = p.pizza_id JOIN 
pizza_types pt ON 
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY orders_count DESC;

-- 9. Average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity), 2) as avg_pizzas_ordered_per_day
FROM (
  SELECT o.date, SUM(od.quantity) AS quantity
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  GROUP BY o.date
) AS order_quantity;

-- 10. Top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price)
AS total_revenue FROM pizzas p JOIN
pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name 
ORDER BY total_revenue DESC
LIMIT 3;

-- 11. Percentage contribution of each pizza category to total revenue.
--CTE approach
WITH grand_total AS(
    SELECT SUM(od.quantity * p.price) AS total_revenue
    FROM order_details od 
    JOIN pizzas p ON 
    od.pizza_id = p.pizza_id)

SELECT pt.category, ROUND(SUM(od.quantity * p.price) * 100.0 /
(SELECT total_revenue FROM grand_total) ,2) AS
revenue_percentage
FROM pizzas p 
JOIN order_details od ON 
p.pizza_id = od.pizza_id JOIN
pizza_types pt ON
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

--subquery approach
SELECT 
    pt.category, 
    ROUND(SUM(od.quantity * p.price) * 100.0 / (
        SELECT SUM(od2.quantity * p2.price) 
        FROM order_details od2
        JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
    ), 2) AS rev_percentage
FROM pizzas p 
JOIN order_details od ON p.pizza_id = od.pizza_id 
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY rev_percentage DESC;

-- 12. Cumulative revenue generated over time.
WITH daily_revenue AS(
SELECT o.date, SUM(od.quantity * p.price) AS daily_rev 
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY o.date
)

SELECT date, SUM(daily_rev) OVER(ORDER BY date) 
AS cumulative_revenue
FROM daily_revenue ORDER BY date;

-- 13. Top 3 most ordered pizza types based on revenue for each category.
WITH pizza_rev AS (
SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM pizzas p JOIN order_details od
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON
p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
ORDER BY total_revenue
),

ranked_pizzas AS (
    SELECT category, name, total_revenue,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY total_revenue DESC)
    AS rn 
    FROM pizza_rev)

SELECT category, name, total_revenue
FROM ranked_pizzas
WHERE rn <= 3
ORDER BY category, total_revenue;



-- Question 1: Peak Hour Basket Dynamics (Lunch vs. Dinner)
-- Business Problem: Calculate the average number of pizzas per order during peak lunch hours (12 PM - 2 PM) 
-- versus peak dinner hours (5 PM - 8 PM) to help store management optimize staffing and oven capacity.
WITH lunch_hour AS (
    SELECT SUM(od.quantity) AS total_pizzas,
    COUNT(DISTINCT o.order_id) AS order_count
    FROM order_details od JOIN
    orders o ON od.order_id = o.order_id
    WHERE strftime('%H', o.time) BETWEEN '12' AND '14'),

dinner_hour AS(
    SELECT SUM(od.quantity) AS total_pizzas,
    COUNT(DISTINCT o.order_id) AS order_count
    FROM order_details od JOIN orders o
    ON od.order_id = o.order_id
    WHERE strftime('%H', o.time) BETWEEN '17' AND '20')

SELECT (l.total_pizzas * 1.0 / l.order_count) AS lunch_avg,
(d.total_pizzas * 1.0 / d.order_count) AS dinner_avg
FROM lunch_hour l, dinner_hour d;


-- Question 2: Common Pairings (Market Basket Analysis)
-- Business Problem: Identify the top pair of two different pizza types that appear together inside the exact same order most frequently 
-- to optimize combo deals and cross-selling strategies.
WITH item_names AS(
    SELECT DISTINCT o.order_id, pt.name 
    AS pizza_name FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id)

SELECT a.pizza_name, b.pizza_name, 
COUNT(*) AS pair_counts
FROM item_names a JOIN item_names b
ON a.order_id = b.order_id
WHERE a.pizza_name < b.pizza_name
GROUP BY a.pizza_name, b.pizza_name
ORDER BY pair_counts DESC LIMIT 1;


-- Question 3: Multi-Item Order Ratio (Basket Breakdown)
-- Business Problem: Analyzing the percentage of single-item versus multi-item orders to 
--understand if sales are driven by solo lunches or group/family dinners.
WITH order_size AS(
    SELECT DISTINCT o.order_id AS orderID, 
    SUM(od.quantity) AS total_volume
    FROM order_details od JOIN orders o
    ON od.order_id = o.order_id
    GROUP BY orderID
)
SELECT total_volume, COUNT(orderID) AS size,
ROUND(COUNT(orderID) * 100.0 / 
(SELECT COUNT(*) FROM order_size), 2) AS percent
FROM order_size
GROUP BY total_volume
ORDER BY size DESC 
;


-- Question 4: Month-over-Month (MoM) Revenue Growth
-- Business Problem: Tracking MoM percentage growth to analyze whether business revenue velocity is improving or declining over time.
WITH revenue_calc AS(
SELECT strftime('%Y-%m', o.date) AS month_num, 
SUM(od.quantity * p.price) AS total_rev
FROM order_details od JOIN orders o
ON od.order_id = o.order_id 
JOIN pizzas p ON
od.pizza_id = p.pizza_id 
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY month_num 
ORDER BY total_rev),

lagged_revenue AS (
    SELECT month_num, total_rev AS current_rev,
    LAG( total_rev) OVER(ORDER BY month_num)
    AS previous_rev FROM revenue_calc)

SELECT 
    CASE substr(month_num, 6, 2)
        WHEN '01' THEN 'January'
        WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'
        WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'
        WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'
        WHEN '08' THEN 'August'
        WHEN '09' THEN 'September'
        WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'
        WHEN '12' THEN 'December'
    END AS month_name,
current_rev, previous_rev,
ROUND(((current_rev - previous_rev) * 100.0 / previous_rev) ,2)
AS MOM_Growth_Pct FROM lagged_revenue;


-- Question 5: Day-of-Week Category Dominance
-- Business Problem: Identifying the single highest-selling pizza category by total order 
-- volume for each day of the week to tune inventory and prep schedules.
WITH best_performer AS (
    SELECT 
        strftime ('%w', o.date) AS days_num,
        CASE strftime('%w', o.date)
        WHEN '0' THEN 'Sunday' 
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END AS days,
    pt.category AS category, 
    SUM(od.quantity) AS total_pizzas 
    FROM order_details od 
    JOIN orders o ON od.order_id = o.order_id 
    JOIN pizzas p ON od.pizza_id = p.pizza_id 
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY strftime ('%w', o.date) , category
),

ranked_category AS (
    SELECT days_num, days, category, total_pizzas,
    ROW_NUMBER() OVER(PARTITION BY days 
    ORDER BY total_pizzas DESC) AS rn
    FROM best_performer
)

SELECT days, category, total_pizzas 
FROM ranked_category
WHERE rn = 1
ORDER BY days_num;



