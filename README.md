# 🛒 Brazilian Olist E-Commerce End-to-End Data Analytics & BI Project

An end-to-end data analytics project analyzing the Brazilian Olist E-Commerce dataset across 99K+ orders (2016–2018). This project covers SQL/Oracle data cleaning, Excel customer cohort & business summary validation, and an interactive Power BI Executive Dashboard built on a Star Schema architecture.

---

## 📌 Project Architecture & Workflow

1. **Data Cleaning & Modeling (SQL / Oracle Database):**
   - Cleaned, normalized, and validated relational datasets.
   - Handled missing values, timestamps, and localized Brazilian product categories into English.
2. **Business Summary & Customer Segmentation (Excel):**
   - Segmented customers by purchase frequency and calculated Average Customer Lifetime Value (CLV).
   - Cross-verified overall gross revenue, order volumes, and average order values.
3. **Data Modeling (Power BI Star Schema):**
   - Implemented a Star Schema with 1-to-Many relationships to optimize filter flow.
   - Developed a dedicated `Dim_Date` calendar table to enable Time Intelligence analytics.
4. **DAX Measures & KPIs:**
   - Authored key business logic inside an isolated `_Measures` table (`Total Revenue`, `Total Orders`, `AOV`, `Delay Rate`, `Avg Review Score`).
5. **Interactive Executive Dashboard:**
   - Designed a dynamic report featuring cross-filtering, Top-10 category rankings, and payment channel distribution.

---

## 🏗️ Data Model (Star Schema)

![Star Schema Data Model](POWER%20BI/DATA_MODELING.png)

### Model Structure:
- **Fact Tables:** `olist_orders_dataset`, `olist_order_items_dataset`
- **Dimension Tables:** `olist_customers_dataset`, `olist_products_dataset`, `olist_sellers_dataset`, `olist_order_payments_dataset`, `olist_order_reviews_dataset`, `Dim_Date`, `product_category_name_translation`

---

## 📊 Executive Overview Dashboard

<img width="873" height="488" alt="DASHBOARD" src="https://github.com/user-attachments/assets/bcaeb191-6f51-4219-9e14-382cb50ac6d4" />
---

## 📈 Excel Customer Segmentation & Lifetime Value

![Excel Business Summary](EXCLE/4_Excel_Summary.png)

---

## ⚙️ Core DAX Measures (`POWER BI/dax_measures.txt`)

```dax
-- Total Revenue
Total Revenue = SUM(olist_order_items_dataset[price])

-- Total Unique Orders
Total Orders = DISTINCTCOUNT(olist_orders_dataset[order_id])

-- Average Order Value (AOV)
AOV = DIVIDE([Total Revenue], [Total Orders], 0)

-- Customer Satisfaction Score
Avg Review Score = AVERAGE(olist_order_reviews_dataset[review_score])

-- Delivery Delay Rate
Delay Rate = 
VAR DelayedOrders = 
    CALCULATE(
        [Total Orders],
        olist_orders_dataset[order_delivered_customer_date] > olist_orders_dataset[order_estimated_delivery_date]
    )
RETURN
DIVIDE(DelayedOrders, [Total Orders], 0)
