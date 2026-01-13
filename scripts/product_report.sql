/*
===============================================================================
 PRODUCT REPORT
 ===============================================================================
 Purpose:
	- This report consolidatess key product metrics and behaviors
 
 Highlights:
	1. Gathers essential fields such as names, category, subcategory.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrcis:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue
		- average monthly spend
 ===============================================================================
 */
 CREATE VIEW gold.report_products AS
 WITH product_details AS (
 /*-----------------------------------------------------------------------------
 1) Base Query: Retrieves core columns from fact_sales and dim_products
 -----------------------------------------------------------------------------*/
 SELECT
	 f.order_number,
	 f.order_date AS order_date,
	 f.customer_key AS customer_key,
	 f.product_key AS product_key,
	 f.sales_amount AS sales_amount,
	 f.quantity AS quantity,
	 p.product_name AS product_name,
	 p.category AS category,
	 p.subcategory AS subcategory,
	 p.cost AS cost
 FROM gold.dim_products p
 LEFT JOIN gold.fact_sales f
 ON f.product_key = p.product_key
 WHERE order_date IS NOT NULL -- only consider valid sales dates
), product_aggregations AS (
/*-----------------------------------------------------------------------------
 2) Second Query: Perform all aggregations
 -----------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity,
	SUM(sales_amount) AS total_sales,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM
	product_details
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
/*-----------------------------------------------------------------------------
 3) Final Query: Combines all product results into one output
 -----------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	CASE WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales >= 10000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- compute average order value
	CASE 
		 WHEN total_orders = 0 THEN total_sales
		 ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- compute average monthly spend
	CASE 
		 WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS avg_monthly_spend
FROM product_aggregations