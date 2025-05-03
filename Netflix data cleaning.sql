-- Data cleaning:

use netflix_raw;
-- Remoove duplicates: find out  which show_ids are duplicated and how many times:
select show_id, count(*) as count 
from df_netflix
group by show_id
having count(*)>1;


-- We dont have duplicates count for show_id cloumn. Lets check this for title column
select * from df_netflix
where  concat (title, type) in(
select concat (title, type) 
from df_netflix
group by title 
having count(*)>1
)
order by title;

--  we remove duplicates, earlier we have 8807 rows and now we have 8803 rows.

-- create new table for several values listed in one column(director, country, cast)
CREATE TABLE director_split AS
WITH RECURSIVE cte AS (
  SELECT show_id, TRIM(SUBSTRING_INDEX(director, ',', 1)) AS director,
         SUBSTRING(director, LENGTH(SUBSTRING_INDEX(director, ',', 1)) + 2) AS rest
  FROM df_netflix WHERE director IS NOT NULL
  UNION ALL
  SELECT show_id, TRIM(SUBSTRING_INDEX(rest, ',', 1)),
         SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM cte WHERE rest != ''
)
SELECT show_id, director FROM cte;


CREATE TABLE country_split AS
WITH RECURSIVE cte AS (
  SELECT show_id, TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
         SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS rest
  FROM df_netflix WHERE country IS NOT NULL
  UNION ALL
  SELECT show_id, TRIM(SUBSTRING_INDEX(rest, ',', 1)),
         SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM cte WHERE rest != ''
)
SELECT show_id, country FROM cte;



CREATE TABLE cast_split AS
WITH RECURSIVE cte AS (
  SELECT show_id, TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS cast,
         SUBSTRING(country, LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS rest
  FROM df_netflix WHERE cast IS NOT NULL
  UNION ALL
  SELECT show_id, TRIM(SUBSTRING_INDEX(rest, ',', 1)),
         SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM cte WHERE rest != ''
)
SELECT show_id, cast FROM cte;

CREATE TABLE genre_split AS
WITH RECURSIVE cte AS (
  SELECT show_id, TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS listed_in,
         SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
  FROM df_netflix WHERE listed_in IS NOT NULL
  UNION ALL
  SELECT show_id, TRIM(SUBSTRING_INDEX(rest, ',', 1)),
         SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM cte WHERE rest != ''
)
SELECT show_id, listed_in FROM cte;


-- data type conversion for date added

-- populate missing values in country, duration columns
insert into country_split
select show_id, m.country 
from df_netflix nr
inner join (
select director, country
 from country_split cs
 inner join director_split ds on cs.show_id=ds.show_id
 group by director, country
 order by director
) m on nr.director= m.director
where nr.country is null;

select * 
from df_netflix
where director='Ahishor Solomon';
-- where director='Ahishor Solomon';
-- this is clear that, we need to populate this.

---------------------
select *
from df_netflix
where duration is null;

-- final table after data cleaning
create table netflix as
with cte as(
select *,
row_number() over (partition by title, type order by show_id asc) as rn
from df_netflix)

select  
show_id, 
type,
title, 
str_to_date(date_added, '%M %d, %Y') as date_added, 
release_year,
rating, 
case when duration is null 
then rating else duration 
end as duration,
description
from cte
where rn=1;
select * from netflix
-- Now we have five tables including raw tables
