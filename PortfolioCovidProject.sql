select * 
from PortfolioProject.dbo.CovidDeath
where continent is not null
order by 2,3

--Data that we are going to be using 

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths, 
	population
from PortfolioProject.dbo.CovidDeath
where continent is not null

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as totalcasedeathratio
from PortfolioProject.dbo.CovidDeath
where location like '%india%'
order by 1,2

--looking at total cases vs population
--shows what percentage population got covid 
--Since total_cases is in nvarchar , changing it into the float

alter table PortfolioProject.dbo.CovidDeath
alter column total_cases float

select location, population, max(total_cases) as infected,max(total_cases/population) * 100 as infectedpercentage
from PortfolioProject.dbo.CovidDeath
--where total_cases is not null
group by location,population 
order by 1 desc

--showing countries with highest death count per population 

select location, max(total_deaths) as totaldeathcount
from PortfolioProject.dbo.CovidDeath
where continent is null
group by location
order by totaldeathcount desc

--breaking down into continent 
select continent, max(total_deaths) as totaldeathcount
from PortfolioProject.dbo.CovidDeath
--where continent is not null
group by continent
order by totaldeathcount desc

--Global Newcases and deaths per day
-- to work on it later

select date
	  ,sum(new_cases) as globalnewcasesperday
	  ,sum(new_deaths) as globaldeathperday
	  -- global death ratio per day 
	  ,(globaldeathperday/globalnewcasesperday)* 100 as globaldeathpercentageperday
from PortfolioProject.dbo.CovidDeath
group by date
order by date

--Total population vs vaccination 

--select * 
--from PortfolioProject.dbo.CovidDeath

--select * 
--from PortfolioProject.dbo.CovidVaccination

select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeath as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--creating cte

with popvsvac(Continent,Location,Date,Population,New_vaccinations,Rollingpeoplevaccinated)
as
(
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeath as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)

select *, (Rollingpeoplevaccinated/population) *100 as PeoplevaccinatedPercent
from popvsvac
order by 2,3

--Temp Table

create table #percentvaccintated
(Continent varchar(255),
 Location varchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )
 
 insert into #percentvaccintated
 select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeath as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 


select *, (Rollingpeoplevaccinated/Population) * 100 as Peoplevaccinatedpercentage
from #percentvaccintated
where Location like '%india%'
order by 2,3


select location, max(population) as maxpopulation
from #percentvaccintated
where Location like '%india%'
group by location
order by 1

-- creating view

create view percentagevaccinated as 
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float )) over (partition by dea.location order by dea.location,dea.date ROWS UNBOUNDED PRECEDING) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeath as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select *, (Rollingpeoplevaccinated/Population) * 100 as Peoplevaccinatedpercentage
from percentagevaccinated









