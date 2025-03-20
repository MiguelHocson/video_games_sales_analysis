-- ========================================================
			 KEY PERFORMANCE INDICATORS (KPIs)	
-- ========================================================


-- ----------------------------
	  	  Total Sales
-- ----------------------------

SELECT 
    SUM(total_sales) AS total_sales
FROM vg_sales;


-- ----------------------------------------
	    Regional Sales Distribution
-- ----------------------------------------

SELECT
	'North America' AS region,
	 SUM(na_sales) AS total_sales
FROM vg_sales
UNION ALL
SELECT
	'Japan' AS region,
	 SUM(jp_sales) AS total_sales
FROM vg_sales
UNION ALL
SELECT
	'Europe & Africa' AS region,
	 SUM(pal_sales) AS total_sales
FROM vg_sales
UNION ALL
SELECT
	'Rest of the World' AS region,
	 SUM(other_sales) AS total_sales
FROM vg_sales
ORDER BY total_sales DESC;



-- ----------------------------------------
	    Top-Selling Games of All Time
-- ----------------------------------------

SELECT
	title,
	SUM(total_sales) AS total_sales
FROM vg_sales
GROUP BY title
ORDER BY total_sales DESC
LIMIT 10;



-- -----------------------------------------
	 Best Performing Consoles of All Time 
-- -----------------------------------------

SELECT
	console,
	SUM(total_sales) AS total_sales
FROM vg_sales
GROUP BY console
ORDER BY total_sales DESC
LIMIT 10;



-- -----------------------------------------
	 Most Popular Game Genres by Sales
-- -----------------------------------------

SELECT
	genre,
	SUM(total_sales) AS total_sales
FROM vg_sales
GROUP BY genre
ORDER BY total_sales DESC
LIMIT 10;



-- -----------------------------------------------
	 Sales Leaders: Best-Performing Publishers
-- -----------------------------------------------

SELECT
	publisher,
	SUM(total_sales) AS total_sales,
	ROUND(AVG(total_sales),2) AS avg_sales
FROM vg_sales
GROUP BY publisher
ORDER BY total_sales DESC
LIMIT 10;



-- --------------------------------------------------
	 Critic Scores vs. Sales: Measuring the Impact
-- --------------------------------------------------

SELECT
	CASE
		WHEN critic_score BETWEEN 0 AND 2 THEN '0-2'
		WHEN critic_score BETWEEN 2 AND 4 THEN '2-4'
		WHEN critic_score BETWEEN 4 AND 6 THEN '4-6'
		WHEN critic_score BETWEEN 6 AND 8 THEN '6-8'
		ELSE '8-10'
	END AS critic_score_group,
	SUM(total_sales) AS total_sales,
	ROUND(AVG(total_sales),2) AS avg_sales
FROM vg_sales
WHERE critic_score IS NOT NULL
GROUP BY critic_score_group
ORDER BY critic_score_group;



-- -----------------------------
	 Video Game Sales Trends
-- -----------------------------

SELECT
	year,
	total_sales,
	SUM(total_sales) OVER(ORDER BY YEAR) AS running_total,
	COALESCE(LAG(total_sales) OVER(),0) AS prev_year_sales,
	CONCAT(ROUND((total_sales - LAG(total_sales) OVER())/LAG(total_sales) OVER(),2) * 100, '%') AS YoY_growth
FROM 
	(SELECT 
		EXTRACT(YEAR FROM release_date) AS year,
		SUM(total_sales) AS total_sales
	 FROM vg_sales
	 GROUP BY EXTRACT(YEAR FROM release_date)
	 ORDER BY YEAR) AS sq
;


