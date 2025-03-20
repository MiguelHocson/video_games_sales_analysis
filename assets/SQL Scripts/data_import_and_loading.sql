-- ========================================================
DATA IMPORT - CREATING AND LOADING TABLE
-- ========================================================

CREATE TABLE vg_sales(
    id SERIAL PRIMARY KEY,  				-- Auto-incrementing unique ID
    title VARCHAR(255) NOT NULL,  			-- Game title
    console VARCHAR(50) NOT NULL,  		-- Platform (PS4, X360, etc.)
    genre VARCHAR(50) NOT NULL,  			-- Game genre
    publisher VARCHAR(255),  				-- Publisher name
    developer VARCHAR(255),  				-- Developer name
    critic_score DECIMAL(3,1),  			-- Critic score (e.g., 9.5)
    total_sales DECIMAL(10,2),  			-- Total sales in millions
    na_sales DECIMAL(10,2),  				-- Sales in North America (millions)
    jp_sales DECIMAL(10,2),  				-- Sales in Japan (millions)
    pal_sales DECIMAL(10,2),  				-- Sales in PAL regions (Europe, etc.) (millions)
    other_sales DECIMAL(10,2),  			-- Sales in other regions (millions)
    release_date DATE,  					-- Release date of the game
    last_update DATE  						-- Date of last data update
);


-- ========================================================
COMMAND IN PSQL to import data from the CSV file
-- ========================================================

SET datestyle = 'DMY'     -- Need to fix datestyle first since the date format of the raw file is in DD/MM/YYYY and PostgreSQL default is YYYY-MM-DD.

\copy public.vg_sales(title, console, genre, publisher, developer, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, release_date, last_update) 
FROM 'C:/Users/Mico/OneDrive/Documents/DATA ANALYTICS/End to End Projects/Video Games/New folder/vgchartz-2024.csv' 
WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8', QUOTE '"', ESCAPE '''');



-- ========================================================
DOUBLE CHECKING IMPORTED DATA
-- ========================================================

SELECT *
FROM vg_sales;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'vg_sales' AND column_name = 'release_date';

