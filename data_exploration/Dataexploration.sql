--SELECT * FROM covid_vacs
--ORDER BY 3,4;

--SELECT * FROM covid_deaths
--ORDER BY 3,4;

SELECT location ,date , total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2


-- Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from covid_deaths
where continent is not null
order by 1,2;


-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from covid_deaths
where location='India' and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_deaths
Where location='India' and continent is not null
order by 1,2;


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_deaths
--Where location='India'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid_deaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--As per the continents with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid_deaths
where continent is null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (CONVERT(float, SUM(cast(new_deaths as int))) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 AS Deathpercentage
From covid_deaths
where continent is not null 
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (CONVERT(float, SUM(cast(new_deaths as int))) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 AS Deathpercentage
From covid_deaths
where continent is not null 
order by 1,2


-- total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vacs as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE

with popvsvac (Continent, Location, Date, Population, New_vaccination, RollingVaccination)

as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vacs as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

select * from popvsvac



with popvsvac (Continent, Location, Date, Population, New_vaccination, RollingVaccination)

as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vacs as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingVaccination/Population)*100
From popvsvac





--Temporary Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vacs as vac
on dea.location=vac.location
and dea.date=vac.date



Select *, (RollingVaccination/Population)*100
From #PercentPopulationVaccinated



-- Creating view for visualizations

Create View  Percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vacs as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


Select * from Percentpopulationvaccinated



