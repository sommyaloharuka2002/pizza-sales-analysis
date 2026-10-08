# Pizza Sales SQL Analysis

SQL analysis of 21,350+ pizza orders using joins, subqueries, and window functions (RANK, cumulative SUM) to uncover revenue trends and category performance — found the Thai Chicken Pizza as the top revenue driver and Classic pizzas contributing 27% of total sales.

## Dataset

Four relational tables:
- `orders` — order ID, date, time
- `order_details` — order ID, pizza ID, quantity
- `pizzas` — pizza ID, type, size, price
- `pizza_types` — pizza type ID, name, category, ingredients

## Tools Used

- MySQL
- SQL Workbench

## Analysis Breakdown

**Basic**
- Total orders placed and total revenue generated
- Highest-priced pizza and most common size ordered
- Top 5 most ordered pizza types

**Intermediate**
- Category-wise order volume and hourly order distribution
- Average pizzas ordered per day
- Top 3 pizza types by revenue

**Advanced**
- Percentage revenue contribution by category
- Cumulative revenue over time (window functions)
- Top 3 pizzas by revenue within each category (RANK, PARTITION BY)

## Key Findings

- **21,350 total orders**, generating **$817,860** in total revenue
- **Thai Chicken Pizza** was the single highest revenue-generating pizza (**$43,434**)
- The **Classic category** led all categories, contributing **26.91%** of total revenue

## Author

Sommya Loharuka

## Acknowledgement

The dataset and project structure were inspired by a publicly available YouTube tutorial. All queries were written, reviewed, and tested independently to deepen my understanding of SQL. This repository reflects my own learning process and practice.