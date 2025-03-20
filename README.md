![image](https://github.com/user-attachments/assets/2c0b1026-5807-4a31-9d96-a8a5a5f4ad72)# SQL Project: Video Games Sales Analysis

# Overview

This SQL project focuses on exploring, cleaning, and transforming video game sales data using PostgreSQL. Through advanced SQL techniques—including joins, window functions, CTEs, GROUP BY, and subqueries—the dataset is thoroughly analyzed to uncover sales trends and identify key sales drivers. 


# Table of Contents

- [Objective](#objective)
- [Data Source](#data-source)
- [Stages](#stages)
- [Design](#design)
- [Development](#development)
  - [Process Outline](#process-outline)
  - [Data Extraction](#data-extraction)
  - [Data Exploration and Cleaning](#data-exploration-and-cleaning)
  - [Data Transformation and Manipulation](#data-transformation-and-manipulation)
  - [Data Modeling](#data-modeling)
- [Visualization](#visualization)
  - [Dashboard](#dashboard)
- [Analysis & Findings](#analysis-and-findings)
- [Recommendations](#recommendations)


# Objective

To analyze video game trends and identify factors that drive sales across platforms, regions, and genres, helping publishers and investors make smarter decisions and maximize success.


# Data Source

The [data](https://www.kaggle.com/datasets/asaniczka/video-game-sales-2024) is sourced from Kaggle (an Excel extract). The dataset consists of columns such as but not limited to:



| Column_Name | Description |
| --- | --- |
| title | Name of Video Game |
| console | Console where game is available |
| genre | Genre of Video Game |
| publisher | Publisher of Video Game | 
| criti_score | Numeric score of Video Game |
| total_sales | Global sales in millions |
| release_date |  Date of first release |


# Stages

- Data Import & Loading
- Data Exploration and Cleaning
- Data Transformation
- Analysis & Findings
- Recommendation


# Data Import & Loading


This is where the dataset was imported and loaded in PostgreSQL. 

1. To import the data, a table was created first.

![data_extraction](assets/images/data_import_create_table.png)

2. Data was then inserted to the table using PSQL command.

 ```sql
-- =========================================================
PSQL command to insert the data into PostgreSQL
-- =========================================================

\copy public.vg_sales(title, console, genre, publisher, developer, critic_score, total_sales, na_sales, jp_sales, pal_sales, other_sales, release_date, last_update) FROM 'C:/Users/Mico/OneDrive/Documents/DATA ANALYTICS/End to End Projects/Video Games/New folder/vgchartz-2024.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', ENCODING 'UTF8', QUOTE '"', ESCAPE '''');![image](https://github.com/user-attachments/assets/defd3ea7-ef3a-42db-aedd-68781c921987)


```  

![data_extraction](assets/images/data_import_insertinto_table.png)



# Data Exploration and Cleaning

This is where the dataset was explored to get familiar with the data structure and data types, as well as to determine if there are any data anomalies such as missing or NULL values, duplicate rows and unusual characters that needs to be corrected. 

1. Checking and removing duplicates.

![data_exploration_cleaning](assets/images/checking_deleting_duplicates.png)

2. Checking and removing any unusual characters.

![data_exploration_cleaning](assets/images/extra_characters_title.png)

![ddata_exploration_cleaning](assets/images/extra_characters_title2.png)

![data_exploration_cleaning](assets/images/unusual_characters_publisher.png)

![data_exploration_cleaning](assets/images/unusual_characters_publisher2.png)

3. Checking and removing any NULL values.

![data_exploration_cleaning](assets/images/remove_null_values2.png)

Additional Notes:

-- Two null values in ‘developer’. The analysis will be based on the ‘publisher’, not the ‘developer’.
-- Multiple null values in ‘critic score’. Trends of missing ‘critic score’ can be analyzed.
-- Null values per ‘region’ are valid as some games may be sold in one region only or not in all regions
-- Null values in ‘last update’ are valid since they indicate if a game has been updated or not.





