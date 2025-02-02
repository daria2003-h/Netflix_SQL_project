# Netflix Movies and TV Shows Data Analysis using SQL
![](https://github.com/daria2003-h/Netflix_SQL_project/blob/main/logo.png)
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
CREATE DATABASE netflix_project_p4;

DROP TABLE IF EXISTS  netflix;
CREATE TABLE netflix
	(show_id VARCHAR(20) PRIMARY KEY,
	type VARCHAR(150),
	title VARCHAR(250),
	director VARCHAR(800),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added DATE,
	release_year INT,
	rating VARCHAR(50) ,
	duration VARCHAR(80),
	listed_in VARCHAR(800),
	description VARCHAR(800)		
	);
```
## Business Problems and Solutions

### 1. Count the number of Movies vs TV Shows
```sql
SELECT 
	type,
	COUNT(*) AS count_number
FROM netflix
GROUP BY type;
```
### 2. Find the most common rating for movies and TV shows
```sql
SELECT * 
FROM
	(SELECT 
		rating,
		type,
		COUNT(show_id) AS count_movies,
		RANK() OVER ( PARTITION BY type ORDER BY COUNT(show_id) DESC) AS rank
	FROM netflix
	GROUP BY rating, type)
WHERE rank = 1;
```
### 3. List all movies released in a specific year (e.g., 2020)
```sql
SELECT 
	show_id, 
	title,
	country,
	release_year,
	rating,
	duration
FROM netflix
WHERE type = 'Movie'
AND release_year = 2020
GROUP  BY show_id;
```
### 4. Find the top 5 countries with the most content on Netflix
```sql
SELECT *
FROM
	(SELECT
		UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
		COUNT(show_id) AS total_content_number,
		RANK() OVER (ORDER BY COUNT(show_id) DESC)AS rank
	FROM netflix
	GROUP BY new_country
	ORDER BY COUNT(show_id) DESC)
WHERE rank <=5 ;
```
### 5. Identify the longest movie
```sql
SELECT 
	show_id,
	title,
	(CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'gi') AS INTEGER))/60
		AS duration_in_hours
FROM netflix
WHERE duration LIKE '%min'
AND type = 'Movie'
ORDER BY duration_in_hours DESC
LIMIT 1;
```
### 6. Find content released in the last 5 years
```sql
SELECT 
	type,
	release_year,
	COUNT(show_id)  AS count_content
FROM netflix
WHERE release_year>=
	(SELECT MAX(release_year - 4) FROM netflix)
GROUP BY 1,2
ORDER BY 1,2;
```
### 7. Find all the movies/TV shows by director 'Barry Avrich'!
```sql
SELECT 
*
FROM
	(SELECT
		UNNEST(STRING_TO_ARRAY(director, ',')) AS director_new,
		show_id,
		type,
		country,
		title
	FROM netflix
	GROUP BY 1,2,3,4)
WHERE director_new = 'Barry Avrich';
```
### 8. List all TV shows with more than 5 seasons
```sql
SELECT *
FROM
(SELECT 
    show_id, 
    title,
    CAST(REGEXP_REPLACE(duration, '[^0-9]', '', 'g') AS INTEGER) AS duration_seasons,
    country,
    release_year
FROM netflix
WHERE type = 'TV Show'
AND duration ~* 'season(s)?')
WHERE duration_seasons > 5
ORDER BY duration_seasons DESC;  
```

### 9. Count the number of content items in each genre
```sql
WITH t1 AS (
    SELECT
        show_id,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
)
, t2 AS (
    SELECT 
        genre,
        COUNT(show_id) AS genre_count
    FROM t1
    GROUP BY genre
)
SELECT 
    genre,
    genre_count,
    RANK() OVER (ORDER BY genre_count DESC) AS genre_rank
FROM t2
ORDER BY genre_count DESC;
```
### 10.Find each year and the  number of content released in United States on netflix. 
--return top 5 year with highest content release
```sql
WITH 
t1
AS
(SELECT 
	show_id,
	release_year,
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country
FROM netflix),
 t2
 AS
	 (SELECT 
		 country,
		 release_year,
		 COUNT(show_id) AS count_content,
		 ROUND(COUNT(*)::numeric/(SELECT COUNT(*) 
		 					FROM netflix 
							WHERE country ='United States')::numeric*100,2) 
		 AS percentage_from_total,
		 RANK() OVER (PARTITION BY country 
		 ORDER BY COUNT(show_id) DESC) AS rank
	 FROM t1
	 GROUP BY country, release_year)
 SELECT *
 FROM t2
 WHERE rank <=5 
 AND country = 'United States'
 ORDER BY rank,release_year;
```
### 11. List all movies that are documentaries
```sql
--Approach 1
SELECT *
FROM 
	(SELECT
		title,
		type,
		TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
	FROM netflix)
WHERE type = 'Movie' AND genre = 'Documentaries'; 

--Approach 2
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%'
		AND type = 'Movie';
```
### 12. Find all content without a director
```sql
SELECT 
	COUNT(*)
FROM netflix
WHERE director IS NULL;
```
### 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%';

SELECT 
    COUNT(show_id) AS salman_khan_movies
FROM netflix
WHERE 
    release_year >= (SELECT MAX(release_year) FROM netflix) - 10
    AND type = 'Movie'
   AND casts ILIKE '%salman khan%';
```
### 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.
```sql
WITH t1
AS 
	(SELECT
		show_id,
		type,
		TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
		TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors
	FROM netflix),
t2 AS 	
	(SELECT
		country,
		actors,
		COUNT(show_id) AS  content_count,
		RANK() OVER (ORDER BY COUNT(show_id) DESC ) AS rank
	FROM t1
	WHERE country = 'United States' AND actors IS NOT NULL
	AND type = 'Movie'
	GROUP BY actors, country)
SELECT *
FROM t2
WHERE rank <= 10;
```

### 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' 
Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
```sql	
SELECT
sensitive_content,
COUNT(show_id) as total_number
FROM 
(SELECT 
	show_id, 
	type,
	title,
	country,
	description,
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
		END AS sensitive_content
FROM netflix)
GROUP BY sensitive_content;
```

