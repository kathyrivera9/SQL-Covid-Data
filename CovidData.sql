Select *
From CovidData..CovidDeaths$
Where continent is not null
order by 3,4


--Select *
--From CovidData..CovidVaccinations$
--order by 3,4

--Select Data we're going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths$
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract Covid in your Country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
Where location like '%states'
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
From CovidData..CovidDeaths$
--Where location like '%states'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
From CovidData..CovidDeaths$
--Where location like '%states'
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries w/ Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths$
--Where location like '%states'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths$
--Where location like '%states'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
--Where location like '%states'
where continent is not null
Group by date
order by 1,2

--Total Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
--Where location like '%states'
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidData..CovidDeaths$ dea
Join CovidData..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From CovidData..CovidDeaths$ dea
	Join CovidData..CovidVaccinations$  vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From CovidData..CovidDeaths$ dea
	Join CovidData..CovidVaccinations$  vac
		on dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From CovidData..CovidDeaths$ dea
	Join CovidData..CovidVaccinations$  vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3

Select * 
From PercentPopulationVaccinated