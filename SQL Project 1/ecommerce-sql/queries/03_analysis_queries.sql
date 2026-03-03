-- ============================================================
-- E-Commerce Analysis Queries (MySQL Version)
-- Topics: JOINs, Aggregations, CTEs, Window Functions
-- Requires: MySQL 8.0+ (for CTEs and Window Functions)
-- ============================================================

-- ============================================================
-- SECTION 1: BASIC JOINS & AGGREGATIONS
-- ============================================================

-- Q1: Total revenue by order status
SELECT
    status,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS gross_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY status
ORDER BY gross_revenue DESC;

-- Q2: Top 5 best-selling products by quantity
SELECT
    p.name AS product_name,
    p.brand,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.subtotal) AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY p.product_id, p.name, p.brand
ORDER BY total_units_sold DESC
LIMIT 5;

-- Q3: Revenue by category
SELECT
    c.name AS category,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.subtotal) AS category_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY c.category_id, c.name
ORDER BY category_revenue DESC;

-- Q4: Average product rating with review count
SELECT
    p.name AS product_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 1) AS avg_rating,
    SUM(CASE WHEN r.is_verified = 1 THEN 1 ELSE 0 END) AS verified_reviews
FROM products p
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY avg_rating DESC, total_reviews DESC;

-- ============================================================
-- SECTION 2: CTEs (Common Table Expressions)
-- ============================================================

-- Q5: Customer Lifetime Value (CLV)
WITH customer_orders AS (
    SELECT
        u.user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS lifetime_value,
        MIN(o.ordered_at) AS first_order,
        MAX(o.ordered_at) AS last_order
    FROM users u
    JOIN orders o ON o.user_id = u.user_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY u.user_id, customer_name
)
SELECT
    customer_name,
    total_orders,
    lifetime_value,
    ROUND(lifetime_value / total_orders, 2) AS avg_order_value,
    DATE(first_order) AS first_order,
    DATE(last_order) AS last_order
FROM customer_orders
ORDER BY lifetime_value DESC;

-- Q6: Low stock products with sales data
WITH sales AS (
    SELECT product_id, SUM(quantity) AS units_sold
    FROM order_items
    GROUP BY product_id
)
SELECT
    p.name AS product_name,
    p.stock_qty AS current_stock,
    p.price,
    COALESCE(s.units_sold, 0) AS units_sold,
    CASE
        WHEN p.stock_qty = 0  THEN 'OUT OF STOCK'
        WHEN p.stock_qty < 20 THEN 'CRITICAL'
        WHEN p.stock_qty < 50 THEN 'LOW'
        ELSE 'OK'
    END AS stock_status
FROM products p
LEFT JOIN sales s ON s.product_id = p.product_id
WHERE p.stock_qty < 50
ORDER BY p.stock_qty ASC;

-- ============================================================
-- SECTION 3: WINDOW FUNCTIONS
-- ============================================================

-- Q7: Rank customers by revenue within each city
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    a.city,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER (
        PARTITION BY a.city
        ORDER BY SUM(o.total_amount) DESC
    ) AS city_rank
FROM users u
JOIN orders o ON o.user_id = u.user_id
JOIN addresses a ON a.address_id = o.address_id
WHERE o.status NOT IN ('cancelled')
GROUP BY u.user_id, customer_name, a.city
ORDER BY a.city, city_rank;

-- Q8: Monthly revenue with running total and MoM growth
WITH monthly AS (
    SELECT
        DATE_FORMAT(ordered_at, '%Y-%m-01') AS month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    WHERE status NOT IN ('cancelled', 'returned')
    GROUP BY DATE_FORMAT(ordered_at, '%Y-%m-01')
)
SELECT
    DATE_FORMAT(month, '%Y-%m') AS month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month) AS running_total,
    ROUND(
        100.0 * (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0), 2
    ) AS pct_change
FROM monthly
ORDER BY month;

-- Q9: Top product per category
WITH ranked AS (
    SELECT
        c.name AS category,
        p.name AS product_name,
        SUM(oi.subtotal) AS revenue,
        RANK() OVER (
            PARTITION BY c.category_id
            ORDER BY SUM(oi.subtotal) DESC
        ) AS rnk
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories c ON c.category_id = p.category_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status NOT IN ('cancelled', 'returned')
    GROUP BY c.category_id, c.name, p.product_id, p.name
)
SELECT category, product_name, revenue
FROM ranked
WHERE rnk = 1
ORDER BY revenue DESC;

-- ============================================================
-- SECTION 4: SUBQUERIES
-- ============================================================

-- Q10: Customers who spent above average
SELECT
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    o.order_id,
    o.total_amount,
    DATE(o.ordered_at) AS order_date
FROM orders o
JOIN users u ON u.user_id = o.user_id
WHERE o.total_amount > (
    SELECT AVG(total_amount) FROM orders WHERE status = 'delivered'
)
AND o.status = 'delivered'
ORDER BY o.total_amount DESC;

-- Q11: Products never ordered
SELECT p.product_id, p.name, p.price, p.stock_qty
FROM products p
WHERE p.product_id NOT IN (
    SELECT DISTINCT product_id FROM order_items
)
ORDER BY p.product_id;

-- Q12: Payment method breakdown
SELECT
    method AS payment_method,
    COUNT(*) AS transactions,
    SUM(amount) AS total_amount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_share
FROM payments
WHERE status = 'completed'
GROUP BY method
ORDER BY total_amount DESC;

-- ============================================================
-- SECTION 5: USEFUL VIEWS
-- ============================================================

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    u.email,
    o.status AS order_status,
    o.total_amount,
    DATE(o.ordered_at) AS order_date,
    p.method AS payment_method,
    p.status AS payment_status
FROM orders o
JOIN users u ON u.user_id = o.user_id
LEFT JOIN payments p ON p.order_id = o.order_id;

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.name AS product_name,
    c.name AS category,
    p.price,
    p.stock_qty,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.subtotal), 0) AS total_revenue,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = oi.order_id
    AND o.status NOT IN ('cancelled', 'returned')
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_id, p.name, c.name, p.price, p.stock_qty;