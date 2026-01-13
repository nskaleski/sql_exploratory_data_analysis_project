/*
===============================================================================
 Data Segmentation

 Group the data based on a specific range.
 Helps understand the correlation between two measures.

 [measure] by [measure]
 total products by sales range
 total customers by age

 Task: segment prodcuts into cost ranges and 
 count how many produts fall into each segment
 ===============================================================================
 */

 WITH cost_range AS (
 SELECT
 product_name,
 CASE WHEN cost < 100 THEN 'Below 100'
	  WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	  WHEN cost BETWEEN 500 and 1000 THEN '500-1000'
	  ELSE 'Above 1000'
  END AS cost_range
 FROM gold.dim_products

 )
 SELECT
 cost_range,
 COUNT(product_name) as num_of_products
 FROM cost_range
 GROUP BY cost_range
 Order by num_of_products DESC

 /*
===============================================================================
 Data Segmentation

 Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than 5,000
	- Regular: Customers with at least 12 months of history but spending 5,000 or less
	- New: Customers with a lifespan less than 12 months.
 ===============================================================================
 */
 WITH customer_spending AS (
 SELECT
 c.customer_key,
 SUM(f.sales_amount) AS total_spending,
 MIN(order_date) AS first_order,
 MAX(order_date) AS last_order,
 DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
 FROM gold.fact_sales f
 LEFT JOIN gold.dim_customers c
 ON f.customer_key = c.customer_key
 GROUP BY c.customer_key
 )
 SELECT
 customer_key,
 total_spending,
 lifespan,
 CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	  WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	  ELSE 'New'
 END customer_segment
 FROM customer_spending

 /*
===============================================================================
 Data Segmentation
 find the total number of customers by each group.
 ===============================================================================
 */

WITH customer_spending AS (
 SELECT
 c.customer_key,
 SUM(f.sales_amount) AS total_spending,
 MIN(order_date) AS first_order,
 MAX(order_date) AS last_order,
 DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
 FROM gold.fact_sales f
 LEFT JOIN gold.dim_customers c
 ON f.customer_key = c.customer_key
 GROUP BY c.customer_key
 )
SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	 SELECT
	 customer_key,
	 CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		  WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		  ELSE 'New'
	 END customer_segment
	 FROM customer_spending) t
 GROUP BY customer_segment
 ORDER BY total_customers DESC