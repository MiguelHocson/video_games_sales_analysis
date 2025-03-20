-- ========================================================
			 KEY REQUIREMENTS AND QUESTIONS 	
-- ========================================================


-- ----------------------------------------------------------------------------------------------------------------------------
--    1. Which years saw record-breaking video game sales (>$100M)? What were the top 3 selling games during those years?
-- ----------------------------------------------------------------------------------------------------------------------------

-- extracting game sales per year
WITH yearly_sales AS (
	SELECT
		EXTRACT(YEAR FROM release_date) AS year,
		title,	
		total_sales
	FROM vg_sales
),

-- Calculating the sum of total sales per year and filtering years where total sales are higher than $100M
highestsales_year AS (
	SELECT 
		year,		
		SUM(total_sales) AS total_sales                
	FROM yearly_sales
	GROUP BY year
	HAVING SUM(total_sales) >= 100.0					
),

-- Ranking sales per year from highest to lowest
sales_ranking AS (
	SELECT
		year,
		title,
		total_sales,
		DENSE_RANK() OVER(PARTITION BY year ORDER BY total_sales DESC) AS rnk
	FROM yearly_sales
)

-- Main Query

SELECT
	sr.year,
	sr.title,
	sr.total_sales
FROM sales_ranking AS sr
INNER JOIN highestsales_year AS hs				-- inner join to return matching columns from both tables
	ON hs.year = sr.year						-- matched ON year to return only years where the sum of total sales > $100M
WHERE sr.rnk IN (1,2,3)							-- filter to return only the top 1 to 3 selling games per year
ORDER BY sr.year;




-- ---------------------------------------------------------------------------------------------------------------------------------
--    2. Which publishers have repeatedly produced the best-selling game of the year? Which games contributed to their success?
-- ---------------------------------------------------------------------------------------------------------------------------------


-- Calculating the sum of total sales per year and title
WITH yearly_sales_title AS (
	SELECT 
		EXTRACT(YEAR FROM release_date) AS year,
		title,
		SUM(total_sales) AS overall_sales                		         		-- overall sales per year and game
	FROM vg_sales
	GROUP BY EXTRACT(YEAR FROM release_date), title
),

-- Ranking the games per year by overall_sales
ranking_overallsales_yearly AS (
	SELECT 
		year,
		title,
		overall_sales,
		DENSE_RANK() OVER(PARTITION BY year ORDER BY overall_sales DESC) AS rnk
	FROM yearly_sales_title
),

-- Respective publishers games with highest overall sales (Rank 1) every year 
top_publishers_yearly AS (
	SELECT
		ro.year,
		ro.title,
		vs.publisher,
		ro.overall_sales
	FROM ranking_overallsales_yearly AS ro
	INNER JOIN vg_sales AS vs
		ON ro.year = EXTRACT(YEAR FROM vs.release_date)
		AND ro.title = vs.title
	WHERE ro.rnk = 1
),

-- Number of times a publisher produced the best-selling game (Nested CTE)
count_appearances AS (
	SELECT
		publisher,
		COUNT(DISTINCT title) AS n_topcount
	FROM top_publishers_yearly
	GROUP BY publisher
)

-- Main Query

SELECT DISTINCT
	tp.publisher,										-- return the publisher
	tp.title,											-- return all the game titles that the publisher produced
	tp.year,											-- return the year when the game was published
	tp.overall_sales 									-- return the corresponding sales of that game, which is the max sales for that year
FROM top_publishers_yearly AS tp
LEFT JOIN count_appearances AS ca						-- Inner join to return matching columns from both tables
	ON tp.publisher = ca.publisher						-- Matched ON publisher to return only those that will match the filter
WHERE ca.n_topcount > 1									-- Filter to return only publishers who produce the best-selling game more than once
ORDER BY tp.publisher, tp.year;



-- ---------------------------------------------------------------------------------------------------------------------------------------
--    3. What are the highest-grossing games that launched on multiple consoles, and which platform generated the highest sales?
-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Highest-grossing games that are available on multiple consoles
WITH multiplatform_games AS (
	SELECT 
		title,
		SUM(total_sales) AS combined_sales,		                     -- Overall sum of a game's total sales across all consoles
		COUNT(DISTINCT console) AS n_consoles                           -- Count of distinct consoles where the game is available
	FROM vg_sales
	GROUP BY title
	HAVING COUNT(DISTINCT console) > 1                                  -- Filter games that are available in more than 1 console
),

-- Returning the most profitable console per game 
top_console AS (
	SELECT
		title,
		console,														 -- Return the console for the highest sales per game
		total_sales
	FROM vg_sales
	WHERE (title, total_sales) IN (SELECT title, MAX(total_sales)       -- Filter only for the maximum sales per game     
									FROM vg_sales
									GROUP BY title)
),

-- Extracting games with the list of consoles where they are available
consoles_list AS (
	SELECT 
		title,
		ARRAY_AGG(DISTINCT console) AS consoles_available               -- Returns a list of distinct consoles where each game is available
	FROM vg_sales
	GROUP BY title
)

-- Main Query

SELECT 
	m.title,
	c.consoles_available,
	t.console AS top_console,
	t.total_sales AS top_console_sales,
	m.combined_sales AS combined_console_sales
FROM multiplatform_games AS m
INNER JOIN top_console AS t												 -- Inner join since there may be games with max sales that are not multiplatform games
	ON m.title = t.title												 -- Joined ON title to return the same game from top_console and multiplatform_game
INNER JOIN consoles_list AS c
	ON m.title = c.title												 -- Joined ON title to return the same game from top_console and consoles_list
ORDER BY m.combined_sales DESC
LIMIT 10;           



-- ---------------------------------------------------------------------------------------------------------------------------------------
--    4. How do multiplatform games impact the overall sales of a publisher compared to single-platformed games? 
-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Overall sales per publisher
WITH overall_sales AS (
	SELECT
		publisher,
		SUM(total_sales) AS overall_sales							
	FROM vg_sales 
	GROUP BY publisher
),

-- sales of single and multi-platformed games per publisher
div_sales AS (
	SELECT
		publisher,
		title,
		SUM(total_sales) AS total_sales,		                    -- Overall sum of a game's total sales across all consoles
		COUNT(DISTINCT console) AS n_consoles                      -- Count of distinct consoles where the game is available
	FROM vg_sales
	GROUP BY publisher, title										-- Grouped by publisher then title to segregate sales and count for single and multi-platformed games
),
singleplatform_sales AS (
	SELECT
		publisher,
		SUM(total_sales) AS total_single_sales						-- Total sales of single platform games per publisher 
	FROM div_sales
	WHERE n_consoles = 1											-- Filter single platform games
	GROUP BY publisher
),
multiplatform_sales AS (
	SELECT
		publisher,
		SUM(total_sales) AS total_multi_sales						-- Total sales of multi-platform games per publisher
	FROM div_sales
	WHERE n_consoles > 1											-- Filter multi-platform games
	GROUP BY publisher
)


SELECT
	o.publisher,
	CONCAT(ROUND((s.total_single_sales / o.overall_sales) * 100, 2), '%') AS perc_singleplatform_games,        -- sales of single platform games / overall sales (per publisher)
	CONCAT(ROUND((m.total_multi_sales / o.overall_sales) * 100, 2), '%') AS perc_multiplatform_games,			 -- sales of multi-platform games / overall sales (per publisher)
	o.overall_sales																								 -- overall sales per publisher
FROM overall_sales AS o
INNER JOIN singleplatform_sales AS s ON o.publisher = s.publisher												 -- Inner join to return publishers with both single and multi-platform games																				 
INNER JOIN multiplatform_sales AS m ON o.publisher = m.publisher												 -- Inner join to return publishers with both single and multi-platform games																		
ORDER BY o.overall_sales DESC
LIMIT 20;



-- --------------------------------------------------------------------------------------------------------------------------------------------------------------
--    5. How often do critic scores align with sales? Which top-rated games struggled commercially, and which low-rated games still sold remarkably well?
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Highly-rated (critic_score: 8-10)
-- Low-rate (critic_score: 1-4)

WITH game_critic_sales AS (
	SELECT
		title,
		ROUND(AVG(critic_score),2) AS avg_critic_score,					-- AVG critic score across all consoles 
		SUM(total_sales) AS total_sales						            -- Sum of total sales across all consoles
	FROM vg_sales
	WHERE critic_score IS NOT NULL											-- filter games with available critic_score only
	GROUP BY title
),
avg_sales AS (
    SELECT AVG(total_sales) AS overall_avg_sales 					        -- Avg sales of games with avaialble critic scores
	FROM game_critic_sales
)


SELECT
	title,
	avg_critic_score,
	total_sales,
	CASE 
        WHEN avg_critic_score <= 4 AND total_sales > overall_avg_sales 
            THEN 'Low-rated High Sales'
        WHEN avg_critic_score >= 8 AND total_sales < overall_avg_sales
            THEN 'High-rated Low Sales'
        ELSE NULL
    END AS category
FROM game_critic_sales, avg_sales											 -- cross join of a scalar value (implicitly joins every single row)
WHERE (avg_critic_score <= 4 AND total_sales > overall_avg_sales) OR
	  (avg_critic_score >= 8 AND total_sales < overall_avg_sales)
ORDER BY avg_critic_score DESC;



-- -----------------------------------------------------------------------------------------------------------------------------------
--    6. Which best-selling games have remained relevant over time, and does the critic score play a role in their longevity?
-- -----------------------------------------------------------------------------------------------------------------------------------

-- total sales per game
WITH game_sales AS (
	SELECT
		title,
		SUM(total_sales) AS total_sales
	FROM vg_sales
	GROUP BY title
),

-- years between release and update dates
update_years AS (
	SELECT 
		title,
		DATE_PART('year', last_update) - DATE_PART('year', release_date) AS years_afterlaunch_update       -- difference in years between update and release dates
	FROM vg_sales
),

-- average critic score per game across all consoles
game_avg_critic_scores AS (
	SELECT 
		title,
		ROUND(AVG(critic_score), 2) AS avg_critic_score				
	FROM vg_sales
	GROUP BY title
)

-- Main Query

SELECT DISTINCT 
	u.title,
	g.total_sales,
	u.years_afterlaunch_update,												-- difference in years between last_update and release_date
	a.avg_critic_score                                                 	-- average critic score per game across all consoles
FROM update_years AS u
LEFT JOIN game_sales AS g
	ON u.title = g.title
LEFT JOIN game_avg_critic_scores AS a
	ON a.title = u.title
WHERE a.avg_critic_score IS NOT NULL AND years_afterlaunch_update >= 3		-- excluding games with no critic_scores and including update years of 3 or more years
ORDER BY total_sales DESC
LIMIT 10;



-- ------------------------------------------------------------------------------------------------------------------
--   7. How do gaming preferences differ across different regions? Which genres lead in sales for each region?
-- ------------------------------------------------------------------------------------------------------------------

WITH regional_genre_sales_count AS (
	SELECT
		'North America' AS region,								-- Region category
		genre,
		SUM(na_sales) AS total_sales,							-- Sum of sales per genre in North America
		COUNT(DISTINCT title) AS n_genres						-- Count of distinct titles per genre in North America (since some titles are available on multiple consoles)
	FROM vg_sales
	WHERE na_sales IS NOT NULL
	GROUP BY genre

UNION ALL													-- Union All to return all rows

	SELECT
		'Japan' AS region,
		genre,
		SUM(jp_sales) AS total_sales,
		COUNT(DISTINCT title) AS n_genres
	FROM vg_sales
	WHERE jp_sales IS NOT NULL
	GROUP BY genre

UNION ALL

	SELECT
		'Europe & Africa' AS region,
		genre,
		SUM(pal_sales) AS total_sales,
		COUNT(DISTINCT title) AS n_genres
	FROM vg_sales
	WHERE pal_sales IS NOT NULL
	GROUP BY genre

UNION ALL

	SELECT
		'Rest of the World' AS region,
		genre,
		SUM(other_sales) AS total_sales,
		COUNT(DISTINCT title) AS n_genres
	FROM vg_sales
	WHERE other_sales IS NOT NULL
	GROUP BY genre
)

-- Main Query

SELECT	
	region, genre, total_sales, n_genres
FROM
	(SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS rnk        -- ranks total_sales per region in descending order 
	FROM regional_genre_sales_count
	) AS sq
WHERE rnk <= 3;																			-- returns top 3 genres per region


