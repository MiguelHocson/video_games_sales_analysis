-- ========================================================
			DATA EXPLORATION AND CLEANING
-- ========================================================


-- ----------------------------------
CHECKING FOR ANY DUPLICATE VALUES
-- ----------------------------------


-- USING WINDOW_FUNCTION
SELECT id
FROM
	(SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY title, console, genre, publisher, developer, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, release_date, last_update) AS rn
	 FROM vg_sales)
WHERE rn <> 1;


-- USING MAX() AND GROUP BY CLAUSE
SELECT MAX(id)
FROM vg_sales
GROUP BY title, console, genre, publisher, developer, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, release_date, last_update
HAVING COUNT(*) > 1;


-- DELETING DUPLICATE VALUES FROM TABLE
DELETE FROM vg_sales
WHERE id IN (SELECT MAX(id)
			 FROM vg_sales
			 GROUP BY title, console, genre, publisher, developer, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, release_date, last_update
			 HAVING COUNT(*) > 1);




-- --------------------------------------------------
CLEANING AND REMOVING EXTRA CHARACTERS FROM 'TITLES'
-- --------------------------------------------------		


-- checking titles with unusual characters as observed during data exploration phase and comparing original title with cleaned title
SELECT title, TRIM(REPLACE(REPLACE(REPLACE(title, '//', ''), '.hack', ''), ':', '')) AS title
FROM vg_sales
WHERE title ILIKE '%.hack%';

-- updating clean values of title in the table 
UPDATE vg_sales
SET title = TRIM(REPLACE(REPLACE(REPLACE(title, '//', ''), '.hack', ''), ':', ''))
WHERE title ILIKE '%.hack%';

-- double checking if table has been updated
SELECT *
FROM vg_sales
WHERE title ILIKE '%.hack%';



-- --------------------------------------------------
CLEANING AND REPLACING VALUES FROM 'PUBLISHER'
-- --------------------------------------------------	


-- checking publisher names with unusual characters as observed during the data exploration phase
SELECT *
FROM vg_sales
WHERE publisher ILIKE '%08%';

-- checking other table values where title and developer is the same 

SELECT *
FROM vg_sales
WHERE (title, developer) IN (SELECT title, developer
							 FROM vg_sales
							 WHERE publisher ILIKE '%08%');

-- updating the publisher name as 'Toby Fox' in the table based from the results above

UPDATE vg_sales
SET publisher = 'Toby Fox'
WHERE publisher ILIKE '%08%';

-- double checking if table has been updated
SELECT *
FROM vg_sales
WHERE publisher ILIKE '%08%';



-- -------------------------
CHECKING FOR NULL VALUES
-- -------------------------

-- Checking null values for total_sales as these values would be irrelevant to the analysis

SELECT *
FROM vg_sales
WHERE total_sales IS NULL or total_sales = 0;

-- Removing null values from the table

DELETE FROM vg_sales
WHERE total_sales IS NULL or total_sales = 0;

-- Checking null values for released_date as these values would be irrelevant to the analysis

SELECT *
FROM vg_sales
WHERE release_date IS NULL

-- Removing null values from the table

DELETE FROM vg_sales
WHERE release_date IS NULL;


SELECT *
FROM vg_sales
WHERE na_sales IS NULL;



-- 2 null values in developer. The analysis will be based on the publisher, not the developer
-- Multiple null_values in critic_score. Trends of missing critic_score will be analyzed
-- Null values per region are valid as some games may be sold in one region only or not in all regions
-- Null values in last_update are valid since they can help indicate whether a game has been updated or not. 
