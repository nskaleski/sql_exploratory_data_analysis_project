/*
===============================================================================
 CUMULATATIVE AGGREGATIONS
 
 normal aggreation checks the performance of each individual row
 cumulative aggregations are to see how the business is growing over time. progression.

NOTE TO REMEMBER:

The ORDER BY clause is invalid in views, inline functions, derived tables,
 subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
 ===============================================================================
 */

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(YEAR, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
) t
