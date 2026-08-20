-- Run this Block by Block, not all at the same time
--Some more analysis (advanced data analysis)
--changes over time
Select 
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT (DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- Cumulative analysis

-- Calculate total sales per month and running total of sales over time 
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales -- running total from total sales per month
FROM (
SELECT
DATETRUNC(month,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date))t -- total sales per month

--Performance Analysis 

/*Analyse the yearly performance of products by comparing their sales to both average sales performance of
product and pervious year's sales*/

WITH yearly_product_sales AS(
SELECT 
YEAR(f.order_date) as order_year,
p.product_name,
SUM(f.sales_amount) as current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date),
p.product_name )
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
Current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
CASE WHEN Current_sales - AVG(current_sales) OVER(PARTITION BY product_name) >0 THEN 'Above Average'
	 WHEN Current_sales - AVG(current_sales) OVER(PARTITION BY product_name) <0 THEN 'Below Average'
	 ELSE 'Average'
END AS avg_change,
--Year-over-year analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN Current_sales -LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) >0 THEN 'Better than PY'
	 WHEN Current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) <0 THEN 'Worse than PY'
	 ELSE 'remain'
END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year

--Part to whole analysis

--Which categories contribute the most ot overall sales?

WITH category_sales AS(
SELECT 
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key =f.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND(CAST(total_sales AS FLOAT)/ CAST(SUM(total_sales) OVER() AS FLOAT) *100, 2),'%') AS percentage_sales
FROM category_sales
ORDER BY total_sales DESC
-- Data segmentation

-- segment products into cost ranges and count how many producs fall into each segment
WITH product_segments AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold.dim_products)
SELECT
cost_range,
COUNT(product_key) as total_products
FROM product_segments
GROUP BY cost_range
ORDER by total_products DESC

/* Group into 3 segments based on spending behaviour:
	-VIP : customers with at least 12 months of history and spending more than $5000
	-Regular: customers with at least 12 months of history but spending $5000 or less
	-New: Customers with a lifespan less than 12 months
And find the total number of customers by each group
*/
WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
Max(order_date) AS last_order,
DATEDIFF(month, MIN(order_date),Max(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
On f.customer_key=c.customer_key
GROUP BY c.customer_key)

SELECT
classification,
Count(customer_key) as total_customers
FROM(
SELECT 
customer_key,
CASE WHEN lifespan >12 and total_spending >5000 THEN 'VIP'
	 WHEN lifespan >12 and total_spending <5000 THEN 'Regular'
	 ELSE 'New'
END AS classification
FROM customer_spending
)t 
GROUP BY classification
ORDER BY total_customers DESC

/* CUSTOMER REPORT
Purpose: 
	-This report consolidates key customer metrics and behaviours

Highlights:
	1. Gathers esential fields such as names, ages, and transaction details
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates KPIs
		- recency(months since last order)
		- average order values
		- average monthly spend
*/
/* Base query: retrieves core columns from tables*/
WITH base_query AS(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key=f.customer_key
WHERE birthdate IS NOT NULL)

/*Customer Aggregations: Summarizes key metrics at the customer level*/

,customer_aggregation AS (
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_order,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date),Max(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,
customer_number,
customer_name,
age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age Between 20 and 29 then '20-29'
	 WHEN age Between 30 and 39 then '30-39'
	 WHEN age Between 40 and 49 then '40-49'
	 ELSE 'Above 50'
END as age_group,
CASE WHEN lifespan >12 and total_sales >5000 THEN 'VIP'
	 WHEN lifespan >12 and total_sales <5000 THEN 'Regular'
	 ELSE 'New'
END AS classification,
last_order_date,
DATEDIFF(month,last_order_date,GETDATE()) AS recency,
total_order,
total_sales,
total_quantity,
total_products,
lifespan,
--Compute Average Order Value
CASE WHEN total_sales =0 THEN 0
	 ELSE total_sales/total_order
END AS average_order_value,
--Compute Average monthly spend
CASE WHEN lifespan=0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_spend
FROM customer_aggregation 
