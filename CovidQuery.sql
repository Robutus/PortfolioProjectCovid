select *
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
order by 3,4; -- Order by location, date

--select *
--from PortfolioProjectCovid..CovidVaccinations$
--order by 3,4; 

-- Select data that will be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying from covid contractions
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 as DeathPerc
from PortfolioProjectCovid..CovidDeaths$
where location = 'Australia'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows percentage of population that has contracted covid
select location, date, total_cases, population, (total_cases/population)*100 as PopPerc
from PortfolioProjectCovid..CovidDeaths$
where location = 'Australia'
order by 1,2

-- Looking at Countries with highest infection rate vs population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopPercInfected
from PortfolioProjectCovid..CovidDeaths$
group by location, population
order by PopPercInfected desc

-- Looking at countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

---- Break data down by continent (correct data)
--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProjectCovid..CovidDeaths$
--where continent is null
--group by location
--order by TotalDeathCount desc

-- Break data down by continent (for Tableau purposes)\
-- Showing continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers per day
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPerc
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
group by date
order by date

-- Global numbers total
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPerc
from PortfolioProjectCovid..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations per day
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVacc
from PortfolioProjectCovid..CovidDeaths$ as dea
join PortfolioProjectCovid..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingTotalVacc)
as 
(
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVacc
from PortfolioProjectCovid..CovidDeaths$ as dea
join PortfolioProjectCovid..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingTotalVacc/population)*100
from PopvsVac

-- Use Temp Table
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVacc numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVacc
from PortfolioProjectCovid..CovidDeaths$ as dea
join PortfolioProjectCovid..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingTotalVacc/population)*100 as PercentageVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later visual
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVacc
from PortfolioProjectCovid..CovidDeaths$ as dea
join PortfolioProjectCovid..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
from PercentPopulationVaccinated