/********************************************************************************************************************
Covid 19 Data Exploration in 2023

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Tableau link: https://public.tableau.com/app/profile/ola.zeyad/viz/Covid2019summary2023/Dashboard1

*********************************************************************************************************************/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by Location,date


/** Select Data to be starting with **/

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by date


/* 
	Total Cases vs Total Deaths
	The percentage of people that dying by covid in my country
*/

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
and Location like '%Afghan%'
order by Location, date


/*
	Total Cases vs Population
	Shows what percentage of population infected with Covid
*/

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Afghan%'
order by Location, date


/** Countries with Highest Infection Rate compared to Population **/

Select Location, Population, MAX(total_cases) as InfectedPeople,  Max((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Afghan%'
Group by Location, Population
order by InfectionPercentage desc


/* Countries with Highest Death Count per Population */

Select Location, MAX(cast(Total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
--Where location like '%Afghan%'
Where continent is not null 
Group by Location
order by TotalDeaths desc



	/********************************
	BREAKING THINGS DOWN BY CONTINENT
	********************************/

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
--Where location like '%Afghan%'
Where continent is not null 
Group by continent
order by TotalDeaths desc



/** GLOBAL NUMBERS **/

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

---------------------------
--select date , sum(new_cases), sum(new_deaths) from covidDeaths where new_cases =0
--Group by date

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases !=0
Group By date
order by 1,2

-----------------------------


/* Total Population vs Vaccinations */

select * from covidVaccinations where total_vaccinations is not null

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by date

----------------------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


/* Using CTE to perform more Calculation on previous query */

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



/* Using Temp Table instead of CTE in previous query */

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




/* Creating View to store data for later visualizations */

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
