Select*
From PortfolioProject.dbo.CovidDeaths
Where Continent is not Null
Order by 3,4

--Select*
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, Date, Total_cases, New_cases, Total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not Null
Order by 1,2

----Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Select Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not Null
Order by 1,2

Select Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and Continent is not Null
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, Date, Population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and Continent is not Null
Order by 1,2

--Look at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Continent is not Null
Group by Location, Population
Order by PercentPopulationInfected Desc

--Showing Countries with the Highest Death Count per Population

Select Location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not Null
Group by Location
Order by TotalDeathCount Desc

--Let's Break Things Down by Continent

Select location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is Null
Group by location
Order by TotalDeathCount Desc

--Showing continents with the highest death count per population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount Desc

--Global Numbers

Select date, SUM(New_cases) As Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, 
SUM(Cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Date
Order by 1,2

--Total World Cases

Select SUM(New_cases) As Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, 
SUM(Cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
Order by 1,2

--Looking at Total Population vs Vaccinations

Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations
From PortfolioProject..CovidVaccinations VAC
Join PortfolioProject..CovidDeaths DEA
	On DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.Continent is not null
Order by 2,3

--SUM of new vaccinations (Rolling Count)

Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.Location, DEA.Date)
as RollingPeopleVaccinated
, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations VAC
Join PortfolioProject..CovidDeaths DEA
	On DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.Continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.Location, DEA.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations VAC
Join PortfolioProject..CovidDeaths DEA
	On DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.Continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.Location, DEA.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations VAC
Join PortfolioProject..CovidDeaths DEA
	On DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.Continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select DEA.Continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.Location, DEA.Date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidVaccinations VAC
Join PortfolioProject..CovidDeaths DEA
	On DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.Continent is not null

Select*
From PercentPopulationVaccinated
