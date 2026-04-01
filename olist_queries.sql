
-- 1. DATA CLEANING
SELECT 
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_delivered_customer_date IS NULL 
      THEN 1 ELSE 0 END) AS missing_delivery_date
FROM olist_orders;

-- 2. MONTHLY REVENUE
SELECT 
  TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month,
  ROUND(SUM(oi.price), 2) AS revenue
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- 3. TOP 5 CATEGORIES
SELECT 
  p.product_category_name AS category,
  ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 5;

-- 4. REVIEW SCORE VS DELIVERY
SELECT 
  r.review_score,
  ROUND(AVG(EXTRACT(EPOCH FROM (
    o.order_delivered_customer_date - 
    o.order_purchase_timestamp)) / 86400), 1) 
  AS avg_delivery_days
FROM olist_order_reviews r
JOIN olist_orders o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score;

-- 5. TOP 5 STATES BY REVENUE
SELECT 
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(oi.price), 2) AS revenue
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 5;

-- 6. TOP 5 SELLERS RANKING
SELECT
  oi.seller_id,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  RANK() OVER (ORDER BY SUM(oi.price) DESC) AS seller_rank
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY seller_rank ASC
LIMIT 5;


