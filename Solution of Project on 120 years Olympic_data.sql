--DATA ANALYSIS of 120 years of Olympic History using SQL with 2 datasets (athletes and athlete_events) containing 4 lakh rows--


--Q1 which team has won the maximum gold medals over the years.
--Solution-1
select* from athletes
select* from athlete_events

with cte as (
select a.team, ae.year, ae.event
from athletes a
left join athlete_events ae on a.id=ae.athlete_id
where medal='Gold'
group by a.team, ae.year, ae.event
)
select team, count(distinct event) as no_of_gold
from cte
group by team
order by no_of_gold desc
------------------------

--Q2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
--Solution-2
select* from athletes
select* from athlete_events

with cte as (
select a.team, ae.year, ae.event
from athletes a
left join athlete_events ae on a.id=ae.athlete_id
where medal='Silver'
group by a.team, ae.year, ae.event
--order by ae.year
)
, cte2 as (
select team, year, count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from cte
group by team,year
)
select team, sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as year_of_max_silver
from cte2
group by team
order by total_silver_medals desc
---------------------------------

--Q3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
--Solution-3
select* from athletes
select* from athlete_events

with cte as (
select a.name, ae.medal, ae.event,ae.year
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
)
select top 1 name, count(1) as no_of_gold
from cte
where medal='Gold' and name not in (select distinct name from cte where medal in ('Silver','Bronze'))
group by name
order by no_of_gold desc
------------------------Alternate Solution of Q3
with cte as (
select name
, count(case when medal='Gold' then medal end) as no_of_gold
, count(case when medal='Silver' then medal end) as no_of_silver
, count(case when medal='Bronze' then medal end) as no_of_bronze
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
--where team='India'
group by name
)
, cte2 as (
select name, no_of_gold, row_number() over(order by no_of_gold desc) as rank
from cte
where no_of_silver=0 and no_of_bronze=0 and no_of_gold>=1
)
select*
from cte2 
where rank=1
------------

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
--Solution-4
select* from athletes
select* from athlete_events

with cte as (
select a.name, ae.year, count(*) as no_of_gold
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where medal='Gold'
group by a.name, ae.year
--order by no_of_gold desc
)
, cte2 as (
select *, rank() over(partition by year order by no_of_gold desc) as rnk
from cte
)
select year, no_of_gold, STRING_AGG(name,',') within group (order by name) as players
from cte2 where rnk=1
group by year, no_of_gold
-------------------------

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
--Solution-5
select* from athletes
select* from athlete_events

with cte as (
select a.team, ae.year, ae.medal, ae.event, ae.sport
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where team='India' and medal in ('Gold','Silver','Bronze')
group by a.team, ae.year, ae.medal, ae.event, ae.sport
--order by ae.year
)
, cte2 as (
select medal, year, sport, event, rank() over(partition by medal order by year,sport) as rnk
from cte
)
select* from cte2
where rnk=1
-----------

--6 find players who won gold medal in summer and winter olympics both.
--Solution-6
select a.name
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where medal='Gold'
group by a.name
having count(distinct season)=2
-------------------------------

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
--Solution-7
select a.name, ae.year
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where medal in ('Gold','Silver','Bronze')
group by a.name, ae.year
having count(distinct medal)=3
------------------------------

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
--Solution-8
select* from athletes
select* from athlete_events

with cte as (
select a.name, ae.games, ae.event, ae.medal, ae.year
from athletes a
inner join athlete_events ae on a.id=ae.athlete_id
where medal='Gold' and season='Summer' and year>=2000
group by a.name, ae.games, ae.event, ae.medal, ae.year
--order by games
)
, cte2 as (
select name, event, games, medal
, lag(year,1) over(partition by name,event order by year) as prev_year, year
, lead(year,1) over(partition by name,event order by year) as next_year
from cte
)
select *
from cte2
where year=prev_year+4 and year=next_year-4
-------------------------------------------
























