select * from coviddeaths
order by 4;

alter table coviddeaths
rename column ï»¿iso_code to iso_code;

select location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths
order by date;
-- death against total cases reported
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Covid_Death_Perc
from coviddeaths
where location like '%Afg%'
order by date;

-- total cases against total population
select location, date, total_cases, population, (total_cases/population)*100 as Covid_Cases_Per
from coviddeaths
order by location;

-- country with higest percentage of deaths w.r.t cases
select location, population, max(total_cases), max(total_deaths), concat(round(sum(total_deaths)/sum(total_cases)*100, 2), '%') as Deaths_Per
from coviddeaths
group by location, population
order by Deaths_Per desc;

-- Country with highest infectious rate and highest cases w.r.t population
select location, population, Max(total_cases) as Highest_Infectious_Count,  round(Max((total_cases/population))*100,2) as Cases_Per
from coviddeaths
group by location, population
order by Cases_Per desc;

-- countries with highest death w.r.t population

select location, population, max(total_cases), max(total_deaths) as Total_Death_Count, round(max((total_deaths/population))*100,2) as Death_Percent
from coviddeaths
group by location, population
order by Death_Percent desc;

-- continet wise case detail
select distinct(continent), sum(new_cases), sum(new_deaths) as Total_Death_Count, round(max((total_deaths/population))*100,2) as Death_Percent
from coviddeaths
group by continent
order by Death_Percent desc;

-- Global Numbers
select date, sum(new_cases), sum(new_deaths), round(sum(new_deaths)/sum(new_cases)*100,2) as death_percentage
from coviddeaths
group by date
order by 1,2;

describe coviddeaths;
-- total deaths recorded
select sum(new_deaths) from coviddeaths;
-- total time span
SELECT 
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM 
    coviddeaths;

select * from covidvaccinations;

select * 
from coviddeaths dea
join covidvaccinations vacc
 on dea.date = vacc.date
 and dea.location = vacc.location;

-- total population vs people vaccinated
select dea.continent, dea.location, dea.date, dea.population, cast(vacc.new_vaccinations as unsigned) as vaccinations
from coviddeaths dea
join covidvaccinations vacc
	on 
		dea.date = vacc.date
		and
        dea.location = vacc.location
order by vaccinations desc;

select dea.continent, dea.location, dea.date, dea.population, cast(vacc.new_vaccinations as unsigned) as vaccinations,
sum(cast(vacc.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vacc
	on 
		dea.date = vacc.date
		and
        dea.location = vacc.location
order by 1,2,3;

-- CTE use for this purpose

with popvsvacc (Continet, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vacc.new_vaccinations as unsigned) as vaccinations,
sum(cast(vacc.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vacc
	on 
		dea.date = vacc.date
		and
        dea.location = vacc.location
order by 1,2,3
)
select *, round((RollingPeopleVaccinated/Population)*100,2) as Vacc_Per from popvsvacc;

-- Creating View for furtehr use
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, cast(vacc.new_vaccinations as unsigned) as vaccinations,
sum(cast(vacc.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vacc
	on 
		dea.date = vacc.date
		and
        dea.location = vacc.location
order by 1,2,3;

select * from PercentPopulationVaccinated;

