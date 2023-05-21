select * from CovidDatabase.dbo.CovidDeaths
order by 3, 4;

--select * from CovidDatabase..CovidVaccinations
--order by 3, 4;

-- Select data that  we are going to use
Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDatabase..CovidDeaths
order by 1,2

-- Looking total cases vs total deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
from CovidDatabase..CovidDeaths
where location like 'Pakistan'
order by 1,2

-- Looking total cases vs population
Select location, date, total_cases, population, total_cases/population*100 as PercentagePopulationEffected
from CovidDatabase..CovidDeaths
where location like 'Pakistan'
order by 1,2

--Looking highest infection rate
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as HighestInfectionRate
from CovidDatabase..CovidDeaths
group by location, population
order by HighestInfectionRate desc

--Showing countries with highest death count per population
Select location, max(total_deaths) as MaximumDeaths
from CovidDatabase..CovidDeaths
where continent is not null
group by location
order by MaximumDeaths desc

Select continent, max(total_deaths) as maximumdeaths
from CovidDatabase..CovidDeaths
where continent is not null
group by continent
order by maximumdeaths desc

Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases,0))*100 as DeathPercentage
from CovidDatabase..CovidDeaths
group by date
order by date

-- Join
Select * 
from CovidDatabase..CovidDeaths dea
Join CovidDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- With CTE
With PopVsVac(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDatabase..CovidDeaths dea Join CovidDatabase..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)

Select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated from PopVsVac

--TEMP Table
drop table if exists #PeopleVaccinated
Create Table #PeopleVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(float,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) 
from CovidDatabase..CovidDeaths dea Join CovidDatabase..CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated from #PeopleVaccinated