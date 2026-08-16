-- 1. المبيعات الشهرية ومعدل النمو الشهري (MoM Revenue Growth)
WITH MonthlySales AS (
    SELECT 
        TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS sales_month,
        ROUND(SUM(i.price), 2) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_orders o
    JOIN olist_order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
)
SELECT 
    sales_month,
    total_revenue,
    total_orders,
    LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) 
        / NULLIF(LAG(total_revenue) OVER (ORDER BY sales_month), 0) * 100, 
        2
    ) AS mom_growth_pct
FROM MonthlySales
ORDER BY sales_month;

-- 2. أفضل 10 فئات منتجات تحقيقاً للإيرادات وترتيبها (Top Categories by Revenue)
WITH CategoryPerformance AS (
    SELECT 
        p.category_name,
        ROUND(SUM(i.price), 2) AS total_sales,
        COUNT(i.order_item_id) AS items_sold,
        ROUND(AVG(i.price), 2) AS avg_item_price
    FROM olist_order_items i
    JOIN vw_products_translated p ON i.product_id = p.product_id
    JOIN olist_orders o ON i.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.category_name
)
SELECT 
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
    category_name,
    total_sales,
    items_sold,
    avg_item_price
FROM CategoryPerformance
FETCH FIRST 10 ROWS ONLY;

-- 3. تأثير تأخر التوصيل على تقييمات العملاء (Impact of Delivery Delay on Review Score)
SELECT 
    f.is_delayed,
    COUNT(DISTINCT f.order_id) AS total_delivered_orders,
    ROUND(AVG(f.actual_delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(COUNT(CASE WHEN r.review_score <= 2 THEN 1 END) * 100.0 / COUNT(*), 2) AS bad_review_rate_pct
FROM vw_orders_fulfillment f
JOIN olist_order_reviews r ON f.order_id = r.order_id
GROUP BY f.is_delayed;

-- 4. تحليل سلوك وطرق الدفع (Payment Methods & Installments Analysis)
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_ticket_size,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- 5. تحليل سلوك العملاء وتكرار الشراء (Customer Repeat Purchase Rate)
WITH CustomerOrders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(p.payment_value) AS total_spent
    FROM olist_customers c
    JOIN olist_orders o ON c.customer_id = o.customer_id
    JOIN olist_order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time Customer'
        WHEN order_count = 2 THEN '2 Orders (Returning)'
        ELSE '3+ Orders (Loyal)'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_customer_base,
    ROUND(AVG(total_spent), 2) AS avg_customer_lifetime_value
FROM CustomerOrders
GROUP BY 
    CASE 
        WHEN order_count = 1 THEN 'One-time Customer'
        WHEN order_count = 2 THEN '2 Orders (Returning)'
        ELSE '3+ Orders (Loyal)'
    END
ORDER BY total_customers DESC;
