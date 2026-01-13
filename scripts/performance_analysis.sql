/*
===============================================================================
 Performance Analysis
 
 Comparing the current value to a target value.
 Helps measure success and compare performance

 Current[measure] - Target[measure]
 current sales - average sales
 curren year sales - previous year sales (YoY analysis)
 current sales - lowest sales

 TASK:
	- Analyze the yearly performance of products
	  by comparing each products sales to both
	  its average sales performance and the previous years sales
 ===============================================================================
 */

 WITH yearly_product_sales AS (
 SELECT
 YEAR(f.order_date) AS order_year,
 p.product_name,
 SUM(f.sales_amount) AS current_sales
 FROM gold.fact_sales f
 LEFT JOIN gold.dim_products p
 ON f.product_key = p.product_key
 WHERE order_date IS NOT NULL
 GROUP BY
 YEAR(f.order_date),
 p.product_name
 )
 SELECT
 order_year,
 product_name,
 current_sales,
 AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
 current_sales - AVG(current_sales) OVER (PARTITION BY product_name) diff_avg,
 CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	  WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	  ELSE 'Average'
 END as avg_change,
 -- year over year analysis
 LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
 current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
 CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	  WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	  ELSE 'No Change'
 END as py_change
 FROM yearly_product_sales
 ORDER BY product_name, order_year