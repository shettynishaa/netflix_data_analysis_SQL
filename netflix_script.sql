DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(220),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

--sample data
SELECT * FROM netflix;

--count of rows in the dataset
SELECT COUNT(*) FROM netflix;

--Business Problems
--Q1. Count the number of Movies and TV Shows
SELECT type, COUNT(*) as content_type
FROM netflix
GROUP BY type;

--Q2.Find the most common ratings for Movies and TV Shows
WITH most_rating as(
	SELECT type, rating, COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY type, rating
)
SELECT type,rating FROM most_rating
WHERE ranking = 1

--Q3. List all the movies released in the specific year 2020
SELECT type,title,release_year
FROM netflix
WHERE type LIKE 'Movie' AND release_year = 2020;

--Q4.Find the top 5 countries with the most common content on Netflix
SELECT
	DISTINCT UNNEST(STRING_TO_ARRAY(country,', ')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

--Q5. Identify the longest movie
SELECT 
    title,
    CAST(REPLACE(duration, ' min', '') AS INTEGER) AS duration_minutes
FROM netflix
WHERE type = 'Movie' 
AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;

--Q6.Find content added in the last 5 years
SELECT title, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 Years';

--Q7.Find all the movie/TV Shows by director 'Rajiv Chilaka'.
SELECT title, type
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'; -- ILIKE searches for the names even if the column is case sensitive.

--Q8.Find all the TV shows with more than 5 seasons
SELECT title, 
	   SPLIT_PART(duration, ' ', 1) as sessions
FROM netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration, ' ', 1) AS NUMERIC) > 5;

--Q9. List all the movies that are documentaries
SELECT title, listed_in
FROM netflix
WHERE type = 'Movie'
AND listed_in ILIKE '%documentaries';

--Q10. Find all the content without director
SELECT title
FROM netflix
WHERE director IS NULL;

--Q11.Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,', ')) as genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1;

--Q12. Find the each year and average number of content release by India on Netflix.
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as year,
	COUNT(*),
	ROUND(CAST(COUNT(*) AS NUMERIC)/CAST((SELECT COUNT(*) FROM netflix WHERE country = 'India') AS NUMERIC) * 100,2) as avg_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 1;

--Q13. Find how many movies actor 'Salman Khan has appeared in last 10 years'.
SELECT title,casts,release_year
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY total_content DESC
LIMIT 10;

--Q15. Categorize the contents based on the keywords like 'kill' and 'violence' in the description field.
--label content containing these words as 'Bad' and others as 'Good'. Count how many items fall under each category.
WITH content_label AS(
SELECT 
	title,
	CASE WHEN 
			description ILIKE '%Kill%' OR
			description ILIKE '%Violence%' THEN 'Bad Content'
		ELSE 'Good Content'
		END category
FROM netflix
)
SELECT Category, 
	   COUNT(*)
FROM content_label
GROUP BY 1;