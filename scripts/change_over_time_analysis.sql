/*
===============================================================================
CHANGE OVER TIME ANALYSIS

Analyze how a measure evolves over time.
Helps track and identify seasonality in your data.

[measure] by [date dimension]
total sales by year
average cost by month
===============================================================================
 */

SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

SELECT
DATETRUNC(month, order_date) as order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)

SELECT
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')