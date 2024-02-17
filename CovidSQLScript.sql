Select *
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

Select *
From Covid_PortfolioProject..CovidVaccinations$
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid_PortfolioProject..CovidDeaths$ 
order by 1,2

-- Looking at Total Cases vs Total Deaths (Percentage of people that die)
-- The shows the likelihood of die in covid is contacted
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
From Covid_PortfolioProject..CovidDeaths$ 
Where location like 'Ni%ia'
order by 1,2

-- Looking at Total Cases vs Population (Percentage of the population that have contracted covid)
Select Location, date,population, total_cases, (total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$ 
Where location like 'Ni%ia'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$
Group by location, population
order by PercentageOfCovidInfected desc

-- Showing countries with Hightest Death Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Select location, Max(cast(total_deaths as int)) as TotalDeathCount
--From Covid_PortfolioProject..CovidDeaths$
--Where continent is null
--Group by location
--order by TotalDeathCount desc

-- Looking at Total Cases vs Total Deaths in continent (Percentage of people that die)
-- The shows the likelihood of die in covid is contacted
Select continent, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
order by 1

-- Looking at Total Cases vs Population in continent (Percentage of the population that have contracted covid)
Select continent, date,population, total_cases, (total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$ 
Where continent is not null
order by 1,2

--Looking at continent with Highest Infection Rate compared to Population
Select continent, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent, population
order by PercentageOfCovidInfected desc

-- GLOBAL NUMBER
Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Covid_PortfolioProject..CovidDeaths$
where continent is not null
Group by date
Order by 1,2

Select  Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Covid_PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
Order by 1,2


-- Joining tables
Select *
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE{Common Table Expressions}
With PopvsVac ( Continent, Locaiton, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using TempTable
Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating Views
Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated

-- [VIEWS]Looking at Total Cases vs Total Deaths in continent (Percentage of people that die)
Create View PercentageOfPeopleThatDie as
Select continent, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
--order by 1

Select *
From PercentageOfPeopleThatDie

-- [VIEWS]Looking at Total Cases vs Population in continent (Percentage of the population that have contracted covid)
Create View PercentageOfPopContractedCovid as
Select continent, date,population, total_cases, (total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$ 
Where continent is not null
--order by 1,2

Select *
From PercentageOfPopContractedCovid

-- [VIEWS]Looking at continent with Highest Infection Rate compared to Population
Create View HighestInfectionRate as
Select continent, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageOfCovidInfected
From Covid_PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent, population
--order by PercentageOfCovidInfected desc

Select *
From HighestInfectionRate

-- [VIEWS]GLOBAL NUMBER
Create Table #GlobalNumber
(
total_cases1 numeric,
total_deaths1 numeric,
DeathPercentage1 numeric
)

Insert into #GlobalNumber
Select  Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Covid_PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
Order by 1,2

Select *
From #GlobalNumber

-- Creating Views #GlobalNumber
Drop View if exists GlobalNumber

Create View GlobalNumber as
Select  Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Covid_PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
--Order by 1,2

Select *
From GlobalNumber

--Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
--From Covid_PortfolioProject..CovidDeaths$
--where continent is not null
--Group by date
--Order by 1,2





-- Joining tables
Select *
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

-- [VIEWS]Looking at Total Population vs Vaccination
Create Table #PopulationVsVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into ##PopulationVsVaccination


Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid_PortfolioProject..CovidDeaths$ dea
Join Covid_PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
