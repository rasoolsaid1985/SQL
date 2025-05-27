use nha;

select * from smoking;

create table smokings like smoking;

select * from smokings;

insert smokings
select * from smoking;

select * from smokings;

SELECT COUNT(*) FROM smokings;

---- total entries in the dataset are 1691 -----


select *,
Row_Number() Over(partition by gender, age, highest_qualification, nationality, ethnicity, gross_income, region, smoke, region, amt_weekends, amt_weekdays, type) as row_num
from smokings;

with duplicate_cte as
(
select *,
Row_Number() Over(partition by gender, age, highest_qualification, nationality, ethnicity, gross_income, region, smoke, region, amt_weekends, amt_weekdays, type) as row_num
from smokings
)
select * from duplicate_cte
where row_num>1;

----there are 36 duplicate in the dateset so we can delete them

with duplicate_cte as
(
select *,
Row_Number() Over(partition by gender, age, highest_qualification, nationality, ethnicity, gross_income, region, smoke, region, amt_weekends, amt_weekdays, type) as row_num
from smokings
)
delete from duplicate_cte
where row_num>1;   
-- the delete doesnot work bcz CTE create temporary view. To delete it we have to create a new table with extra column row_num


CREATE TABLE `smoking1` (
  `gender` text,
  `age` int DEFAULT NULL,
  `marital_status` text,
  `highest_qualification` text,
  `nationality` text,
  `ethnicity` text,
  `gross_income` text,
  `region` text,
  `smoke` text,
  `amt_weekends` text,
  `amt_weekdays` text,
  `type` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from smoking1;

insert into smoking1
select *,
Row_Number() Over(partition by gender, age, highest_qualification, nationality, ethnicity, gross_income, region, smoke, region, amt_weekends, amt_weekdays, type) as row_num
from smokings;

select count(*) from smoking1
where row_num>1;

SET SQL_SAFE_UPDATES = 0;
Delete from smoking1
where row_num>1;
SET SQL_SAFE_UPDATES = 1;

select count(*) from smoking1;

describe smoking1;

select count(*) from smoking1
where type = '' or type is null;
-- only type has missing values and they are 1234

CREATE TABLE smoker_only AS
SELECT *
FROM smoking1
WHERE smoke = 'yes';

select * from smoker_only;

select * from smoking1;

-- Now we will check any repeatations of name or entries 

select distinct gender from smoking1;
select gender, count(*) as count
from smoking1
group by gender;

select distinct(nationality), avg (age), count(smoke) as smoke
from smoker_only
group by nationality; 
-- This shows that white over 40 are mostly smokers
-- People with no qualification are more vunerable to smoking
-- Age 40-50 is the most smokers consist
-- Single avg age smokers is 31 and married smokers age is 43
-- Avg age of marriage is above 40 
-- peope age 40+ of north and Midlands & east anglia are highly smokers
-- People age 46 earning between 5k to 10k have high probability of smoking
-- Britishers Scottish and English above 40 are smokers

SELECT COUNT(*) AS total_people FROM smoking1;
select distinct smoke, count(*) from smoking1 group by smoke;
-- total rows are 1655
-- 421 are smokers
-- 1234 are non smokers

select gender, avg(age)
from smoking1
group by gender;

select distinct marital_status, count(smoke)
from smoking1
where smoke='Yes'
group by marital_status;

-- Single 158, Married 143, Seperated 22, Divorces 58 and Widow 40

select distinct(gross_income), count(gross_income) as No_of_People
from smoking1
where smoke = 'Yes'
group by gross_income;
-- the highest earning aggregate is 5-10k and also they are among the highes smokers

select distinct (type), count(smoke) from smoking1
group by type;
-- most people 297 use packets cigeerates

SELECT 
    AVG(amt_weekends) AS avg_weekend,
    AVG(amt_weekdays) AS avg_weekday
FROM smoking1
WHERE smoke = 'Yes';

select gender, (AVG(amt_weekends) + AVG(amt_weekdays)) / 2.0 as avg_cigs_per_day
from smoking1
where smoke='Yes'
group by gender;
-- on avg in a day frmale tkae 13 cig and male take 17 cigs


SELECT smoke, AVG(age) AS average_age
FROM smoking1
GROUP BY smoke;
-- avg age of smoker is 42 whereas non smoker avg age is 52

select highest_qualification, count(*) as count
from smoking1
where smoke='Yes'
group by highest_qualification
order by count desc
limit 1;

select gross_income, highest_qualification, count(*) as count
from smoking1
group by gross_income, highest_qualification;
-- people salaried between 5-10k and not educated are highest smokers

SELECT 
    age,
    smoke,
    COUNT(*) OVER (ORDER BY age ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM smoking1
WHERE smoke = 'Yes';

select gender, 
sum(
case
when smoke='Yes'
then 1
else 0
end
)*100/count(*) as smoker_per
from smoking1
group by gender;

select age, count(smoke) as count 
from smoking1
where smoke='Yes'
group by age
order by count desc
limit 3;

-- people age 28 contain highest number of smoker 

select gender,
sum(case when smoke='Yes' then 1 else 0 end) as smoker,
sum(case when smoke='No' then 1 else 0 end) as non_smoker
from smoking1
group by gender;
-- out of total females 234 are smokers and 709 are non smoker
-- whereas 187 men are smokers and 525 are non smokers


select gender,
sum(case when smoke='Yes' then 1 else 0 end) as smoker,
sum(case when smoke='No' then 1 else 0 end) as non_smoker,
ROUND(100.0 * SUM(CASE WHEN smoke = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS per_smoker,
ROUND(100.0 * SUM(CASE WHEN smoke = 'No' THEN 1 ELSE 0 END) / COUNT(*), 2) AS per_non_smoker
from smoking1
group by gender;
-- 75 percent of the females are no smokers while 73 percent of the male are non smokers
-- 25 percent of the females are smokers and 26 percent of the males are smokers