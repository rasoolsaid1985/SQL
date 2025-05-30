select * from layoffs;

Create table layoffs_staging
like layoffs;

select * from layoffs_staging;

Insert layoffs_staging
select * from layoffs;

select * from layoffs_staging;

-- Duplicate Removal --
select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, country, 'date') As row_num
from layoffs_staging;

with duplicate_cte As
(
select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, country, 'date', stage, funds_raised_millions) As row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num >1;

with duplicate_cte As
(
select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, country, 'date', stage, funds_raised_millions) As row_num
from layoffs_staging
)
delete from duplicate_cte
where row_num >1;

select * from layoffs_staging
where company='casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2 
select *,
Row_Number() Over(
Partition By company, location, industry, total_laid_off, percentage_laid_off, country, 'date', stage, funds_raised_millions) As row_num
from layoffs_staging;

select * from layoffs_staging2
where row_num > 1;

SET SQL_SAFE_UPDATES = 0;
Delete from layoffs_staging2
where row_num >1;
SET SQL_SAFE_UPDATES = 1;

DESCRIBE layoffs_staging2;

select * from layoffs_staging2;

select  company, Trim(company) as Company
from layoffs_staging2;

SET SQL_SAFE_UPDATES = 0;
update layoffs_staging2
set company = Trim(company);

select * 
from layoffs_staging2
where industry  like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry from layoffs_staging2;

select *
from layoffs_staging2
where country like 'United States%';

select distinct country, Trim(Trailing '.' from country) as Country
from layoffs_staging2;

update layoffs_staging2 
set country = Trim(Trailing '.' from country)
where country like 'United States%';

select date,
str_to_date(date, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(date, '%m/%d/%Y');

select date from layoffs_staging2;

alter table layoffs_staging2
modify column date date;

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select t1.industry, t2.industry from 
layoffs_staging2 t1
Join layoffs_staging2 t2
on t1.company = t2.company
and t1.location=t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
 on t1.company=t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

update layoffs_staging2
set industry = Null
where industry = '';

select * from layoffs_staging2
where company like 'Bally%';

select * from layoffs_staging2
where total_laid_off is null 
and
percentage_laid_off is null;

Delete from layoffs_staging2
where total_laid_off is null 
and
percentage_laid_off is null;

Alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;

select Max(total_laid_off), Max(percentage_laid_off)
from layoffs_staging2;

select * from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc;

select company, Sum(total_laid_off) from layoffs_staging2
group by company
order by 2 desc;

select Min(date), Max(date)
from layoffs_staging2;

select country, Sum(total_laid_off) from layoffs_staging2
group by country	
order by 2 desc;

select Year(date), Sum(total_laid_off) from layoffs_staging2
group by year(date)	
order by 1 desc;

select stage, Sum(total_laid_off) from layoffs_staging2
group by stage order by 2 desc;

select substring(date,6,2) as month
from layoffs_staging2;

select substring(date,1,7) as month, sum(total_laid_off)
from layoffs_staging2
where substring(date,1,7) is not null
group by month
order by 1 asc;

with rolling_total as
(
select substring(date,1,7) as month, sum(total_laid_off) as total_laid
from layoffs_staging2
where substring(date,1,7) is not null
group by month	
order by 1 asc
)
select month, total_laid, sum(total_laid) over(order by month) as rolling_total
from rolling_total;

select company, Year(date), sum(total_laid_off)
from layoffs_staging2
group by company, Year(date)
order by 3 desc;

with companyyear (Company, Year, Total_Laid_Off) as 
(
select company, Year(date), sum(total_laid_off)
from layoffs_staging2
group by company, Year(date)
order by 3 desc
), Company_Year_Rank As
(
select *, dense_rank() over(partition by Year order by Total_Laid_Off desc) as Ranking
from companyyear
where Year is not null	
)
select * from Company_Year_Rank
where Ranking <=5;
