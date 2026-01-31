
-- =========================================================
-- Day 1: Core SQL Analytics
-- Project: SQL Sales & Customer Analytics
-- Database: PostgreSQL
-- =========================================================

-- Q1: Monthly Revenue Trend
-- Business Question:
-- How much revenue is generated each month from delivered orders?

SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY 1
ORDER BY 1;

------------------------------------------------------------

-- Q2: Top 10 Customers by Lifetime Value
-- Business Question:
-- Who are the top 10 customers based on total spending?

SELECT
    c.customer_id,
    c.name,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC
LIMIT 10;

------------------------------------------------------------

-- Q3: New vs Repeat Customers per Month
-- Business Question:
-- How many new customers vs repeat customers do we have each month?

WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(DISTINCT CASE WHEN o.order_date = f.first_order_date THEN o.customer_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN o.order_date > f.first_order_date THEN o.customer_id END) AS repeat_customers
FROM orders o
JOIN first_orders f ON o.customer_id = f.customer_id
GROUP BY 1
ORDER BY 1;

------------------------------------------------------------

-- Q4: Revenue by Product Category
-- Business Question:
-- Which product categories generate the highest revenue?

SELECT
    cat.category_name,
    SUM(oi.quantity * oi.price) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY category_revenue DESC;

------------------------------------------------------------

-- Q5: Top 5 Products per Month
-- Business Question:
-- What are the top 5 revenue-generating products for each month?

WITH product_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        oi.product_id,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1, oi.product_id
)
SELECT *
FROM (
    SELECT
        month,
        product_id,
        revenue,
        RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank
    FROM product_sales
) ranked
WHERE rank <= 5
ORDER BY month, rank;

------------------------------------------------------------

-- Q6: Inactive Customers (Churn Indicator)
-- Business Question:
-- Which customers have not placed any orders in the last 6 months?

SELECT
    customer_id,
    MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
HAVING MAX(order_date) < CURRENT_DATE - INTERVAL '6 months';

------------------------------------------------------------

-- Q7: Product Return Rate
-- Business Question:
-- Which products have the highest return rates?

SELECT
    p.product_id,
    p.product_name,
    COUNT(r.return_id)::DECIMAL / COUNT(oi.order_item_id) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
GROUP BY p.product_id, p.product_name
ORDER BY return_rate DESC;

------------------------------------------------------------

-- Q8: Average Order Value (AOV) per Month
-- Business Question:
-- What is the average order value per month?

SELECT
    DATE_TRUNC('month', order_date) AS month,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE order_status = 'DELIVERED'
GROUP BY 1
ORDER BY 1;

------------------------------------------------------------

-- Q9: Time Gap Between Customer Orders
-- Business Question:
-- How many days pass between consecutive orders for each customer?

SELECT
    customer_id,
    order_date,
    order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_last_order
FROM orders
ORDER BY customer_id, order_date;

------------------------------------------------------------

-- Q10: Orders Contributing to Top 80% Revenue (Pareto Analysis)
-- Business Question:
-- Which orders contribute to the top 80% of total revenue?

WITH revenue_ranked AS (
    SELECT
        order_id,
        total_amount,
        SUM(total_amount) OVER (ORDER BY total_amount DESC) AS running_revenue,
        SUM(total_amount) OVER () AS total_revenue
    FROM orders
    WHERE order_status = 'DELIVERED'
)
SELECT *
FROM revenue_ranked
WHERE running_revenue <= 0.8 * total_revenue;
