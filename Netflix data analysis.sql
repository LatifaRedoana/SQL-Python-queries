
-- netflix data analysis
-- Q1: For each director count the no. of movies and TV shows created by them, fro each director who have created TV shows and movies both.
select ds.director, count(distinct n.type) as distinct_type
from netflix n
inner join director_split ds on n.show_id=ds.show_id
group by ds.director
having count(distinct n.type)>1
order by distinct_type desc;-- the name of the director created movies and tv shows more

-- And

select ds.director 
,count(distinct case when n.type='Movie' then n.show_id end) as No_Movies
,count(distinct case when n.type='TV show' then n.show_id end) as No_TVshow
from netflix n
inner join director_split ds on n.show_id=ds.show_id
group by ds.director
having count(distinct n.type)>1
order by distinct_type desc;
-- so we get how many no of movies and tvshows are directed by the director who directed both.alter


-- Q2: which country has highest number of comedy movies?
select gs.show_id, listed_in, cs.country
from genre_split gs
inner join country_split cs on cs.show_id= gs.show_id
where gs.listed_in='comedies';-- this will give us list of comedy movies country

-- and for that

select cs.country, count(distinct gs.show_id) as no_of_movies
from genre_split gs
inner join country_split cs on cs.show_id= gs.show_id
inner join netflix n on gs.show_id=n.show_id
where gs.listed_in='comedies' and n.type='movie'
group by cs.country
order by no_of_movies desc
limit 1;

-- Q3: for each year (as per date added to the netflix), which director has maximum no. of movies released

with cte as(
select ds.director, year(date_added) as date_year, count( n.show_id) as no_of_movies
from netflix n
inner join director_split ds on ds.show_id= n.show_id
where type='movie'
group by ds.director, year(date_added) 
)
,cte2 as(
select *
, row_number() over (partition by date_year order by no_of_movies desc, director) as rn
from cte)
select * 
from cte2  where rn=1;
-- order by date_year, no_of_movies desc; -- for each director each year, how many movies are released 

-- Q4: What is the average duration of movies in each genre
select gs.listed_in, avg(cast(replace(duration, 'min', '') as unsigned)) as avg_duration
from netflix n
inner join  genre_split gs on n.show_id= gs.show_id
where type='Movie'
group by gs.listed_in;

-- 5: Find the list of director who have created comedy and horror movie both

select ds.director
, count( distinct case when gs.listed_in='comedies' then n.show_id end) as no_of_comedy
, count( distinct case when gs.listed_in='horror movies' then n.show_id end) as no_of_horror
from netflix n
inner join genre_split gs on gs.show_id=n.show_id
inner join  director_split ds on ds.show_id=n.show_id
where type='movie' and gs.listed_in in('comedies', 'Horror movies')
group by ds.director 
having count(distinct gs.listed_in)=2;

-- for example:
select * from genre_split where show_id in
(select show_id from director_split where director='steve brill')
order by listed_in