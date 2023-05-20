CREATE DATABASE olist_store;
USE olist_store;

#1.Weekday Vs Weekend (order purchase timestamp) Payment Statistics.
SELECT IF(weekday(oo.order_purchase_timestamp)>4,"Weekend","Weekday") AS weekday_type,ROUND(SUM(op.payment_value),2) AS Payment_Value
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_payments_dataset op
ON oo.order_id=op.order_id
GROUP BY weekday_type;

CREATE TABLE kpi1 AS 
SELECT IF(weekday(oo.order_purchase_timestamp)>4,"Weekend","Weekday") AS weekday_type,ROUND(SUM(op.payment_value),2) AS Payment_Value
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_payments_dataset op
ON oo.order_id=op.order_id
GROUP BY weekday_type;

#2.Number of orders with review_score 5 and payment type as credit_card.
SELECT IF((payment_type="credit_card" and review_score=5),"5*_Credit_Card","Others") AS Review_Type,count(*) AS Orders_Count
FROM olist_store.olist_order_reviews_dataset_csv ord INNER JOIN olist_store.olist_order_payments_dataset op
ON ord.order_id=op.order_id
GROUP BY review_type
ORDER BY Orders_count;

CREATE TABLE kpi2 AS
SELECT IF((payment_type="credit_card" and review_score=5),"5*_Credit_Card","Others") AS Review_Type,count(*) AS Orders_Count
FROM olist_store.olist_order_reviews_dataset_csv ord INNER JOIN olist_store.olist_order_payments_dataset op
ON ord.order_id=op.order_id
GROUP BY review_type
ORDER BY Orders_count;

#3.Average number of days taken for order_delivered_customer_date for pet shop.
SELECT product_category_name,ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS Shipping_Days
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_items_dataset oi ON
oo.order_id=oi.order_id 
INNER JOIN olist_store.olist_products_dataset op ON oi.product_id=op.product_id
WHERE product_category_name="pet_shop"
GROUP BY product_category_name;

CREATE TABLE kpi3 AS
SELECT product_category_name,ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS Shipping_Days
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_items_dataset oi ON
oo.order_id=oi.order_id 
INNER JOIN olist_store.olist_products_dataset op ON oi.product_id=op.product_id
WHERE product_category_name="pet_shop"
GROUP BY product_category_name;

#4.Average price and Payment values from customer of Sao Paulo city.
SELECT customer_city,ROUND(AVG(payment_value)) AS Payment_Value,ROUND(AVG(price)) AS Price
FROM olist_store.olist_orders_dataset2 oo INNER JOIN olist_store.olist_order_items_dataset oi 
ON oo.order_id=oi.order_id
INNER JOIN olist_store.olist_order_payments_dataset op ON oo.order_id=op.order_id
INNER JOIN olist_store.olist_customers_dataset oc ON oo.customer_id=oc.customer_id
WHERE customer_city="sao paulo";

CREATE TABLE kpi4 AS
SELECT customer_city,ROUND(AVG(payment_value)) AS Payment_Value,ROUND(AVG(price)) AS Price
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_items_dataset oi 
ON oo.order_id=oi.order_id
INNER JOIN olist_store.olist_order_payments_dataset op ON oo.order_id=op.order_id
INNER JOIN olist_store.olist_customers_dataset oc ON oo.customer_id=oc.customer_id
WHERE customer_city="sao paulo";

#5.Relationship between shipping days Vs review score.

SELECT Review_Score,ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS Shipping_Days
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_reviews_dataset_csv ord
ON oo.order_id=ord.order_id
GROUP BY review_score
ORDER BY review_score;

CREATE TABLE kpi5 AS
SELECT Review_Score,ROUND(AVG(DATEDIFF(order_delivered_customer_date,order_purchase_timestamp)),2) AS Shipping_Days
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_reviews_dataset_csv ord
ON oo.order_id=ord.order_id
GROUP BY review_score
ORDER BY review_score;

#6.Show the top 3 product categories in year 2018 by payment value.
with CTE_top3 AS (
SELECT product_category_name_english AS Product_Category, ROUND(SUM(payment_value)) AS Total_Payment,
DENSE_RANK() OVER (ORDER BY SUM(payment_value) DESC) AS rnk
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_payments_dataset opt ON oo.order_id=opt.order_id
INNER JOIN olist_store.olist_order_items_dataset oid ON oo.order_id=oid.order_id
INNER JOIN olist_store.olist_products_dataset op ON 
oid.product_id=op.product_id
INNER JOIN olist_store.product_category_name_translation opc ON op.product_category_name=opc.product_category_name_english
WHERE year(order_purchase_timestamp)=2018
GROUP BY product_category_name_english
)
SELECT Product_category, Total_Payment
FROM CTE_Top3
WHERE rnk<=3;

#7.Show top 5 cities with highest payment value.

SELECT customer_city,ROUND(SUM(payment_value)) AS Total_Payment 
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_payments_dataset op ON oo.order_id=op.order_id
INNER JOIN olist_store.olist_customers_dataset oc ON oo.customer_id=oc.customer_id
GROUP BY customer_city
ORDER BY Total_payment desc
limit 5;

#8. Show payment wise top 5 product categories and show top 3 cities of those product categories.

WITH CTE AS (
SELECT product_category_name_english,customer_city,round(sum(payment_value)) as Total_Payment,
DENSE_RANK() OVER (PARTITION BY product_category_name_english ORDER BY SUM(payment_value) DESC) as rnk
FROM olist_store.olist_orders_dataset oo INNER JOIN olist_store.olist_order_payments_dataset op ON oo.order_id=op.order_id
INNER JOIN olist_store.olist_customers_dataset oc ON oo.customer_id=oc.customer_id
INNER JOIN olist_store.olist_order_items_dataset ooi ON oo.order_id=ooi.order_id
INNER JOIN olist_store.olist_products_dataset opt ON ooi.product_id=opt.product_id
INNER JOIN olist_store.product_category_name_translation opcn ON opt.product_category_name=opcn.product_category_name_english
GROUP BY product_category_name_english,customer_city
ORDER BY rnk
)
SELECT product_category_name_english AS Product_Category,
GROUP_CONCAT(customer_city) as Customer_City FROM CTE
WHERE rnk<=3
GROUP BY product_category_name_english
limit 5;



#=====================================================================================================================================================
ALTER TABLE olist_store.olist_orders_dataset
MODIFY COLUMN order_purchase_timestamp datetime;

ALTER TABLE olist_store.olist_orders_dataset
MODIFY COLUMN order_delivered_customer_date datetime;

ALTER TABLE olist_store.olist_orders_dataset
MODIFY COLUMN order_estimated_delivery_date datetime;

ALTER TABLE olist_store.olist_orders_dataset
add column order_delivered_customer_date_ datetime;





