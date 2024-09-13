LOAD DATA INFILE 'C:/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ','  -- Specify delimiter (comma in this case)
ENCLOSED BY '"'           -- Specify if fields are enclosed by quotes (optional)
LINES TERMINATED BY '\n'  -- Specify row terminator (newline in this case)
IGNORE 1 ROWS;     

truncate table netflix;
use don;
show tables;
select director from netflix where show_id='s2';
update netflix set country=null where country="";
select * from netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows


select type,count(*)
from
netflix group by type;

-- 2. Find the most common rating for movies and TV shows

select * 
from (select rating,type,
	  dense_rank() over(partition by type order by c desc) d 
	  from (select rating,type,count(*) c
			from netflix 
            group by rating,type 
            order by count(*) desc )s1) g2
where d=1;

-- 3. List all movies released in a specific year (e.g., 2020)
select * 
from netflix 
where type="Movie" 
	  and release_year=2020;


-- 4. Find the top 5 countries with the most content on Netflix


select SUBSTRING_INDEX(country,",",1) NEW_COUNTRY,
	    count(*) c
from netflix 
where country is not null 
group by 1 
order by c desc 
limit 5;



-- 5. Identify the longest movie
select title,duration 
from netflix 
where type="Movie" 
	  and
	  duration=(select max(duration) 
				from netflix 
                where type="Movie");


-- 6. Find content added in the last 5 years
select * 
from netflix 
where str_to_date(date_added,'%M %d,%Y')>current_date ()- interval 5 year;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * 
from netflix 
where director like "%Rajiv Chilaka";


-- 8. List all TV shows with more than 5 seasons
SELECT * 
FROM (SELECT *,SUBSTRING(duration,1,1) TB
      FROM NETFLIX) S2 
WHERE TB>5;


-- 9. Count the number of content items in each genre

SELECT substring_index(listed_in,',',1) genre
		,count(*) 
from NETFLIX 
group by 1;
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

select year(str_to_date(date_added,'%M %d, %Y')) d1
			,count(*),
            COUNT(*)/(select count(*)
					  FROM NETFLIX
					  where country="INDIA") * 100
from netflix
where country="INDIA"
group by d1;
 
 
 select count(*) FROM NETFLIX
 where country="INDIA";
-- 11. List all movies that are documentaries
SELECT * 
FROM NETFLIX 
WHERE LISTED_IN 
	  LIKE '%DOCUMENTARIES%';
-- 12. Find all content without a director
SELECT * 
FROM NETFLIX 
WHERE DIRECTOR IS NULL;
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM NETFLIX 
WHERE CASTS LIKE '%SALMAN KHAN%' 
	  and release_year > year(curdate()-interval 10 year);
      
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    SUBSTRING_INDEX(casts, ',', 1) AS actor,
    COUNT(*) AS c 
FROM netflix 
WHERE country LIKE '%india%' 
  AND casts IS NOT NULL 
GROUP BY actor 
ORDER BY c DESC 
LIMIT 5;


-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
with cte12 as(
select title,
case when
description like '%kill%' or description like '%violence%'  then 'bad'
else 'good' end category from netflix)
select category, count(*) from cte12 group by category;


