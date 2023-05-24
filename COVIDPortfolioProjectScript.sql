Select * 
From PortfolioProject..CovidDeaths
--Where continent is not NULL
order by 2,4

--Select *
--From CovidVaccinations
--order by 3,4

-- Select data we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country (rough)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select Location, date, Population, total_cases, (total_cases/Population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By location, population
Order By PercentPopulationInfected desc

--Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
--Where location like '%states%'
Group By location
Order By TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
--Group By date
Order By 1,2

--Looking at total population vs vaccinations
--Total amount of people in world that have been vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date 
Where dea.continent is not NULL
Order By 2,3

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date 
Where dea.continent is not NULL
--Order By 2,3
)

Select *
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date 
Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date 
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated