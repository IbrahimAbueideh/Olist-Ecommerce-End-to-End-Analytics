-- 1. View لربط المنتجات بترجمتها الإنجليزية ومعالجة القيم المفقودة
CREATE OR REPLACE VIEW vw_products_translated AS
SELECT 
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Other') AS category_name,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_products p
LEFT JOIN product_category_translation t 
    ON p.product_category_name = t.product_category_name;

-- 2. View لتحليل أداء الطلبات وفترات الشحن والتوصيل الفعلي مقابل المتوقع
CREATE OR REPLACE VIEW vw_orders_fulfillment AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    -- حساب مدة التوصيل الفعلية بالأيام
    ROUND(CAST(order_delivered_customer_date AS DATE) - CAST(order_purchase_timestamp AS DATE), 1) AS actual_delivery_days,
    -- حساب مدة التوصيل المتوقعة بالأيام
    ROUND(CAST(order_estimated_delivery_date AS DATE) - CAST(order_purchase_timestamp AS DATE), 1) AS estimated_delivery_days,
    -- مؤشر: هل الطلب تأخر عن الموعد المتوقع؟ (1 = متأخر، 0 = في الموعد)
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
        ELSE 0 
    END AS is_delayed
FROM olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
