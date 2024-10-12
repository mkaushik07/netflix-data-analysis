--  Netflix project start
use netflix;

drop table if exists netflix;
create table netflix(
show_id varchar(100),
ctype varchar(100),
title varchar(250),
director varchar(550),	
cast varchar(1000),	
country	varchar(350),	
date_added	varchar(250),	
release_year int,
rating	varchar(210),	
duration varchar(220),	
listed_in varchar(300),	
cdescription varchar(750)
);

-- 1. Count the number of movies vs tv shows 
select ctype,count(*) as total 
from netflix
group by ctype;

-- 2. Find the most common rating for movies and tv shows

select ctype,
rating 
from(
	select ctype,
	rating,
	count(*) as c,
	Rank() over(partition by ctype order by count(*)desc) ranking
	from netflix
	group by 1,2
) as result
where ranking =1;


-- 3. List all movies released in a specified year
select title
from netflix 
where ctype = "Movie" and release_year = 2018;

-- 4. Find the top 5 countries with most content on netflix
select country, count(show_id)  as total_content
from netflix
where country is not null and country !=""
group by country
order by count(show_id) desc
limit 5 offset 0 ; 

-- 5. Identify the longest movie

-- using subquery
select title from netflix where duration = (select max(duration) from netflix
where ctype = "Movie"); 

-- using window function
select title, duration from
(select title,
duration,
rank() over (partition by ctype order by duration desc) as ranking
from netflix 
where ctype="Movie") as n
 where ranking = 1;

-- 6. Find the content added in the last 5 years 

select *,str_to_date(date_added,"%M %d, %Y")  as dates
from netflix
where year(str_to_date(date_added,"%M %d, %Y")) >=2021 ;

-- 7. Find all the movies and tv shows directed by "Masahiko Murata" director

select title
from netflix where director LIKE "%Masahiko Murata%";
-- we have seen some of the director names are joined so to find out particularly from this director we can use LIKE function  

-- 8. Find the TV Shows which run for more than 2 seasons

Select title,cast((substring_index(duration," ",1)) as signed) as num_of_seasons
from netflix
where ctype = "TV Show" and cast((substring_index(duration," ",1)) as signed) >2;

-- 9. List all movies that are documentaries

select title,listed_in,release_year,date_added,cdescription
from netflix
where listed_in LIKE "%Documentaries%" and ctype="Movie";

-- 10. Find all content without a director

select * 
from netflix 
where director is null or director= ""; 


-- 11.  Categorize the content based on the presence of the keywords 'Kill' or "Violence" in the description. Label content containing 
--  these keywords as 'Bad' and all other as "Good". Count how many items fall into each category

with results as(
select *,
case 
	when lower(cdescription) like "%kill%" or lower(cdescription) like "%violation%" then "Bad_content"
    else "Good_content"
end category
from netflix
)

select category, count(*)
from results 
group by 1;

	