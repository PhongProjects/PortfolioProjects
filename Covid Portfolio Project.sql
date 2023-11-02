------------------------------------------------------------------------------------------------------------------------------------------
--TABLES WE WILL BE USING

SELECT*
FROM PortfolioProject.dbo.CovidDeaths

SELECT*
FROM PortfolioProject.dbo.CovidVaccinations

------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location, Date, Total_Cases, New_cases, Total_deaths, Population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

------------------------------------------------------------------------------------------------------------------------------------------------
--TOTAL CASES VS TOTAL DEATHS

SELECT Location, Date, Total_deaths, Total_Cases, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

------------------------------------------------------------------------------------------------------------------------------------------------
--TOTAL CASES VS TOTAL DEATHS FOR UNITED STATES

SELECT Location, Date, Total_deaths, Total_Cases, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1, 2

------------------------------------------------------------------------------------------------------------------------------------------------
-- TOTAL CASES VS POPULATION FOR UNITED STATES

SELECT Location, Date, Total_Cases, Population, (Total_Cases/Population)*100 AS InfectionRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1, 2

------------------------------------------------------------------------------------------------------------------------
--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount, MAX((Total_Cases/Population))*100 PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC, Population DESC

------------------------------------------------------------------------------------------------------------------------
--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(CONVERT(Int,Total_Deaths)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

------------------------------------------------------------------------------------------------------------------------
--BREAK DOWN BY CONTINENTS
SELECT Continent, MAX(CONVERT(Int,Total_Deaths)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

------------------------------------------------------------------------------------------------------------------------
--GLOBAL NUMBERS

SELECT SUM(New_Cases) AS TotalCases, SUM(CONVERT(INT,New_Deaths)) AS TotalDeaths,
	   SUM(CONVERT(INT,New_Deaths))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths

------------------------------------------------------------------------------------------------------------------------
--SHOWING ROLLING POPULATION VACCINATED

SELECT D.Continent, D.Location, D.Date, D.Population, New_Vaccinations,
	   SUM(CONVERT(INT,New_Vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.Location = V.Location
	AND D.Date = V.Date
WHERE D.Continent IS NOT NULL 
ORDER BY D.Location, D.Date ASC
--------------------------------------------------------------------------------------------------
--SHOWING TOTAL POPULATION VACCINATED 

SELECT D.Continent, D.Location, D.Date, D.Population, New_Vaccinations,
	   SUM(CONVERT(INT,New_Vaccinations)) OVER (PARTITION BY D.Location) AS TotalPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.Location = V.Location
	AND D.Date = V.Date
WHERE D.Continent IS NOT NULL 
ORDER BY D.Location, D.Date ASC

---------------------------------------------------------------------------------------------------------------------------------
--USING CTE TO SHOW POPULATION VS ROLLING VACCINATIONS

WITH CTE AS 
(
SELECT D.Continent, D.Location, D.Date, D.Population, New_Vaccinations,
	   SUM(CONVERT(INT,New_Vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.Location = V.Location
	AND D.Date = V.Date
WHERE D.Continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM CTE

----------------------------------------------------------------------------------------------------------------------------------
--USING TEMP TABLE TO SHOW POPULATION VS VACCINATIONS

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC)

INSERT INTO #PercentPopulationVaccinated
SELECT D.Continent, D.Location, D.Date, D.Population, New_Vaccinations,
	   SUM(CONVERT(INT,New_Vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.Location = V.Location
	AND D.Date = V.Date
WHERE D.Continent IS NOT NULL 

SELECT*, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

----------------------------------------------------------------------------------------------------------------------------------
--CREATING VIEW TO STORE LATER FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.Continent, D.Location, D.Date, D.Population, New_Vaccinations,
	   SUM(CONVERT(INT,New_Vaccinations)) OVER (PARTITION BY D.Location ORDER BY D.Location, D.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS D
JOIN PortfolioProject.dbo.CovidVaccinations AS V
	ON D.Location = V.Location
	AND D.Date = V.Date
WHERE D.Continent IS NOT NULL 

----------------------------------------------------------------------------------------------------------------------------------