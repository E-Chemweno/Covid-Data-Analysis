SELECT *
FROM [SQL Porfolio Project]..['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM [SQL Porfolio Project]..['CovidVaccinations']
--ORDER BY 3,4

--Looking at Total Cases VS Total Deaths
--Shows the likelihood of dying if you contract COVID in Kenya
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM [SQL Porfolio Project]..['CovidDeaths']
WHERE location LIKE 'Kenya' AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected 
FROM [SQL Porfolio Project]..['CovidDeaths']
WHERE location LIKE 'Kenya'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentPopulationInfected 
FROM [SQL Porfolio Project]..['CovidDeaths']
--WHERE location LIKE 'Kenya'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest DeathCount per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM [SQL Porfolio Project]..['CovidDeaths']
--WHERE location LIKE 'Kenya'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



--SHOWING THE DATA BY CONTINENT

--Showing the continent with the Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM [SQL Porfolio Project]..['CovidDeaths']
--WHERE location LIKE 'Kenya'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(total_cases) AS TotalCases, SUM(total_deaths) AS TotalDeaths, (SUM(total_deaths)/SUM(total_cases))*100 AS DeathPercentage
FROM [SQL Porfolio Project]..['CovidDeaths']
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1


--Looking at Total Population Vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQL Porfolio Project]..['CovidDeaths'] dea
JOIN [SQL Porfolio Project]..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location LIKE 'Kenya'
ORDER BY 2,3

--USING CTE

WITH PopulationVsVaccinations (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQL Porfolio Project]..['CovidDeaths'] dea
JOIN [SQL Porfolio Project]..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location LIKE 'Kenya'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopulationVsVaccinations


--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQL Porfolio Project]..['CovidDeaths'] dea
JOIN [SQL Porfolio Project]..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location LIKE 'Kenya'
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


--CREATING VIEWS TO STORE DATA FOR LATER VISALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQL Porfolio Project]..['CovidDeaths'] dea
JOIN [SQL Porfolio Project]..['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location LIKE 'Kenya'
--ORDER BY 2,3
