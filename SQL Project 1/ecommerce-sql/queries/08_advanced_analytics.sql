-- ============================================================
-- Advanced Analytics Queries (MySQL 8.0+)
-- Topics: RFM Analysis, Cohort Analysis, Basket Analysis,
--         Churn Detection, YoY Growth
-- Author: Koukuntla Shiva Darshan
-- ============================================================

-- ============================================================
-- Q13: RFM ANALYSIS (Recency, Frequency, Monetary)
-- Segments customers into Gold / Silver / Bronze tiers
-- ============================================================
WITH
    rfm_raw AS (
        SELECT
            u.user_id,
            CONCAT(
                u.first_name,
                ' ',
                u.last_name
            ) AS customer_name,
            DATEDIFF(CURDATE(), MAX(o.ordered_at)) AS recency_days,
            COUNT(DISTINCT o.order_id) AS frequency,
            SUM(o.total_amount) AS monetary
        FROM users u
            JOIN orders o ON o.user_id = u.user_id
        WHERE
            o.status NOT IN('cancelled', 'returned')
        GROUP BY
            u.user_id,
            customer_name
    ),
    rfm_scored AS (
        SELECT
            *,
            NTILE(3) OVER (
                ORDER BY recency_days ASC
            ) AS r_score,
            NTILE(3) OVER (
                ORDER BY frequency DESC
            ) AS f_score,
            NTILE(3) OVER (
                ORDER BY monetary DESC
            ) AS m_score
        FROM rfm_raw
    )
SELECT
    customer_name,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 8 THEN '🥇 Gold'
        WHEN (r_score + f_score + m_score) >= 5 THEN '🥈 Silver'
        ELSE '🥉 Bronze'
    END AS segment
FROM rfm_scored
ORDER BY rfm_total DESC, monetary DESC;

-- ============================================================
-- Q14: COHORT ANALYSIS — Monthly Retention
-- Groups customers by their first purchase month
-- ============================================================
WITH
    first_purchase AS (
        SELECT user_id, DATE_FORMAT(MIN(ordered_at), '%Y-%m') AS cohort_month
        FROM orders
        WHERE
            status NOT IN('cancelled', 'returned')
        GROUP BY
            user_id
    ),
    activity AS (
        SELECT
            fp.cohort_month,
            DATE_FORMAT(o.ordered_at, '%Y-%m') AS activity_month,
            COUNT(DISTINCT o.user_id) AS active_users
        FROM orders o
            JOIN first_purchase fp ON fp.user_id = o.user_id
        WHERE
            o.status NOT IN('cancelled', 'returned')
        GROUP BY
            fp.cohort_month,
            activity_month
    )
SELECT
    cohort_month,
    activity_month,
    active_users,
    TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(
            CONCAT(cohort_month, '-01'),
            '%Y-%m-%d'
        ),
        STR_TO_DATE(
            CONCAT(activity_month, '-01'),
            '%Y-%m-%d'
        )
    ) AS months_since_first
FROM activity
ORDER BY cohort_month, activity_month;

-- ============================================================
-- Q15: BASKET ANALYSIS — Products Frequently Bought Together
-- Finds product pairs that appear in the same order
-- ============================================================
SELECT
    p1.name AS product_a,
    p2.name AS product_b,
    COUNT(*) AS times_bought_together
FROM
    order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id
    AND oi1.product_id < oi2.product_id
    JOIN products p1 ON p1.product_id = oi1.product_id
    JOIN products p2 ON p2.product_id = oi2.product_id
    JOIN orders o ON o.order_id = oi1.order_id
WHERE
    o.status NOT IN('cancelled', 'returned')
GROUP BY
    oi1.product_id,
    oi2.product_id,
    p1.name,
    p2.name
ORDER BY times_bought_together DESC
LIMIT 10;

-- ============================================================
-- Q16: CUSTOMER CHURN DETECTION
-- Customers who haven't ordered in the last 60 days
-- ============================================================
SELECT
    u.user_id,
    CONCAT(
        u.first_name,
        ' ',
        u.last_name
    ) AS customer_name,
    u.email,
    MAX(o.ordered_at) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.ordered_at)) AS days_since_last_order,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_spend,
    CASE
        WHEN DATEDIFF(CURDATE(), MAX(o.ordered_at)) > 365 THEN '🔴 Churned'
        WHEN DATEDIFF(CURDATE(), MAX(o.ordered_at)) > 180 THEN '🟠 At Risk'
        WHEN DATEDIFF(CURDATE(), MAX(o.ordered_at)) > 60 THEN '🟡 Cooling'
        ELSE '🟢 Active'
    END AS churn_status
FROM users u
    LEFT JOIN orders o ON o.user_id = u.user_id
    AND o.status NOT IN('cancelled', 'returned')
GROUP BY
    u.user_id,
    customer_name,
    u.email
ORDER BY days_since_last_order DESC;

-- ============================================================
-- Q17: REVENUE BY DAY OF WEEK
-- Understand which days drive the most sales
-- ============================================================
SELECT
    DAYNAME(ordered_at) AS day_of_week,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE
    status NOT IN('cancelled', 'returned')
GROUP BY
    DAYNAME(ordered_at),
    DAYOFWEEK(ordered_at)
ORDER BY DAYOFWEEK(ordered_at);

-- ============================================================
-- Q18: CATEGORY GROWTH — Compare revenue across time periods
-- ============================================================
WITH
    category_monthly AS (
        SELECT c.name AS category, DATE_FORMAT(o.ordered_at, '%Y-%m') AS month, SUM(oi.subtotal) AS revenue
        FROM
            order_items oi
            JOIN products p ON p.product_id = oi.product_id
            JOIN categories c ON c.category_id = p.category_id
            JOIN orders o ON o.order_id = oi.order_id
        WHERE
            o.status NOT IN('cancelled', 'returned')
        GROUP BY
            c.category_id,
            c.name,
            DATE_FORMAT(o.ordered_at, '%Y-%m')
    )
SELECT
    category,
    month,
    revenue,
    LAG(revenue) OVER (
        PARTITION BY
            category
        ORDER BY month
    ) AS prev_month_revenue,
    ROUND(
        100.0 * (
            revenue - LAG(revenue) OVER (
                PARTITION BY
                    category
                ORDER BY month
            )
        ) / NULLIF(
            LAG(revenue) OVER (
                PARTITION BY
                    category
                ORDER BY month
            ),
            0
        ),
        2
    ) AS growth_pct
FROM category_monthly
ORDER BY category, month;

-- ============================================================
-- Q19: CUSTOMER PURCHASE GAPS
-- Average days between orders for repeat customers
-- ============================================================
WITH
    ordered AS (
        SELECT
            user_id,
            ordered_at,
            LAG(ordered_at) OVER (
                PARTITION BY
                    user_id
                ORDER BY ordered_at
            ) AS prev_order
        FROM orders
        WHERE
            status NOT IN('cancelled', 'returned')
    )
SELECT
    u.user_id,
    CONCAT(
        u.first_name,
        ' ',
        u.last_name
    ) AS customer_name,
    COUNT(*) AS repeat_purchases,
    ROUND(
        AVG(
            DATEDIFF(ordered_at, prev_order)
        ),
        1
    ) AS avg_days_between_orders
FROM ordered o
    JOIN users u ON u.user_id = o.user_id
WHERE
    o.prev_order IS NOT NULL
GROUP BY
    u.user_id,
    customer_name
ORDER BY avg_days_between_orders ASC;