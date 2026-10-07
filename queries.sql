USE dimensional_report_db;


-- Query 1: Rank products by total revenue
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS revenue_rank
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 2: Dense rank products by total revenue
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS revenue_rank
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 3: Assign row numbers to products by revenue
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    ROW_NUMBER() OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS row_num
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 4: Rank products within each category
SELECT
    dc.category_name,
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    RANK() OVER (
        PARTITION BY dc.category_name
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS category_rank
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name, dp.product_name;


-- Query 5: Rank customers by total spending
SELECT
    dc.customer_name,
    SUM(fs.quantity * fs.unit_price) AS total_spending,
    RANK() OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS spending_rank
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_id = dc.customer_id
GROUP BY dc.customer_name;


-- Query 6: Rank customers within each city
SELECT
    dc.city,
    dc.customer_name,
    SUM(fs.quantity * fs.unit_price) AS total_spending,
    RANK() OVER (
        PARTITION BY dc.city
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS city_rank
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_id = dc.customer_id
GROUP BY dc.city, dc.customer_name;


-- Query 7: Divide products into four revenue groups
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    NTILE(4) OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS revenue_group
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 8: Compare each product's revenue with the previous product
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    LAG(SUM(fs.quantity * fs.unit_price)) OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS previous_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 9: Compare each product's revenue with the next product
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    LEAD(SUM(fs.quantity * fs.unit_price)) OVER (
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS next_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 10: Rank products within categories using DENSE_RANK
SELECT
    dc.category_name,
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY dc.category_name
        ORDER BY SUM(fs.quantity * fs.unit_price) DESC
    ) AS category_rank
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name, dp.product_name;


	-- Query 11: Calculate monthly revenue
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT *
	FROM monthly_sales
	ORDER BY year, month;


	-- Query 12: Calculate previous month's revenue using LAG
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT
		month_name,
		revenue,
		LAG(revenue) OVER (
			ORDER BY year, month
		) AS previous_month_revenue
	FROM monthly_sales
	ORDER BY year, month;


	-- Query 13: Calculate month-over-month revenue difference
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT
		month_name,
		revenue,
		LAG(revenue) OVER (
			ORDER BY year, month
		) AS previous_month_revenue,
		revenue - LAG(revenue) OVER (
			ORDER BY year, month
		) AS revenue_difference
	FROM monthly_sales
	ORDER BY year, month;


	-- Query 14: Calculate month-over-month growth percentage
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT
		month_name,
		revenue,
		LAG(revenue) OVER (
			ORDER BY year, month
		) AS previous_month_revenue,
		ROUND(
			(
				revenue - LAG(revenue) OVER (
					ORDER BY year, month
				)
			) /
			NULLIF(
				LAG(revenue) OVER (
					ORDER BY year, month
				), 0
			) * 100,
			2
		) AS mom_growth_percentage
	FROM monthly_sales
	ORDER BY year, month;


	-- Query 15: Show only months with positive MoM growth
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	),
	mom_report AS (
		SELECT
			month_name,
			revenue,
			revenue - LAG(revenue) OVER (
				ORDER BY year, month
			) AS revenue_difference
		FROM monthly_sales
	)
	SELECT *
	FROM mom_report
	WHERE revenue_difference > 0;


	-- Query 16: Show only months with negative MoM growth
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	),
	mom_report AS (
		SELECT
			month_name,
			revenue,
			revenue - LAG(revenue) OVER (
				ORDER BY year, month
			) AS revenue_difference
		FROM monthly_sales
	)
	SELECT *
	FROM mom_report
	WHERE revenue_difference < 0;


	-- Query 17: Calculate monthly quantity sold
	WITH monthly_quantity AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity) AS total_quantity
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT *
	FROM monthly_quantity
	ORDER BY year, month;


	-- Query 18: Compare monthly quantity with previous month
	WITH monthly_quantity AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity) AS total_quantity
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT
		month_name,
		total_quantity,
		LAG(total_quantity) OVER (
			ORDER BY year, month
		) AS previous_month_quantity
	FROM monthly_quantity
	ORDER BY year, month;


	-- Query 19: Calculate monthly revenue growth percentage
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	),
	mom_growth AS (
		SELECT
			month_name,
			revenue,
			LAG(revenue) OVER (
				ORDER BY year, month
			) AS previous_revenue
		FROM monthly_sales
	)
	SELECT
		month_name,
		revenue,
		previous_revenue,
		ROUND(
			(revenue - previous_revenue) /
			NULLIF(previous_revenue, 0) * 100,
			2
		) AS growth_percentage
	FROM mom_growth;


	-- Query 20: Find the month with the highest revenue
	WITH monthly_sales AS (
		SELECT
			dd.year,
			dd.month,
			dd.month_name,
			SUM(fs.quantity * fs.unit_price) AS revenue
		FROM fact_sales fs
		JOIN dim_date dd
			ON fs.date_id = dd.date_id
		GROUP BY dd.year, dd.month, dd.month_name
	)
	SELECT
		month_name,
		revenue
	FROM monthly_sales
	ORDER BY revenue DESC
	LIMIT 1;

-- Query 21: Revenue by category
SELECT
    dc.category_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name;


-- Query 22: Revenue by category with overall total using ROLLUP
SELECT
    dc.category_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name WITH ROLLUP;


-- Query 23: Revenue by category and product
SELECT
    dc.category_name,
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name, dp.product_name;


-- Query 24: Category and product totals using ROLLUP
SELECT
    dc.category_name,
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name, dp.product_name WITH ROLLUP;


-- Query 25: Revenue by year and month
SELECT
    dd.year,
    dd.month,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_date dd
    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;


-- Query 26: Year and month totals using ROLLUP
SELECT
    dd.year,
    dd.month,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_date dd
    ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month WITH ROLLUP;


-- Query 27: Revenue by city
SELECT
    dc.city,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_id = dc.customer_id
GROUP BY dc.city
ORDER BY total_revenue DESC;


-- Query 28: City revenue with overall total using ROLLUP
SELECT
    dc.city,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_id = dc.customer_id
GROUP BY dc.city WITH ROLLUP;


-- Query 29: Category-wise quantity sold
SELECT
    dc.category_name,
    SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name;


-- Query 30: Category quantity with overall total using ROLLUP
SELECT
    dc.category_name,
    SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_category dc
    ON dp.category_id = dc.category_id
GROUP BY dc.category_name WITH ROLLUP;


-- Query 31: Examine the execution plan for a sales query
EXPLAIN
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;


-- Query 32: Examine the execution plan for customer sales
EXPLAIN
SELECT
    dc.customer_name,
    SUM(fs.quantity * fs.unit_price) AS total_spending
FROM fact_sales fs
JOIN dim_customer dc
    ON fs.customer_id = dc.customer_id
GROUP BY dc.customer_name;


-- Query 33: Create an index on the fact table's product_id
CREATE INDEX idx_fact_sales_product
ON fact_sales(product_id);


-- Query 34: Create an index on the fact table's customer_id
CREATE INDEX idx_fact_sales_customer
ON fact_sales(customer_id);


-- Query 35: Examine the execution plan after adding indexes
EXPLAIN
SELECT
    dp.product_name,
    SUM(fs.quantity * fs.unit_price) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
GROUP BY dp.product_name;