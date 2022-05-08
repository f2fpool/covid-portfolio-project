SELECT *
FROM PortfolioProject.dbo.covid_deaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject.dbo.covid_vaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.covid_deaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in our country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM PortfolioProject.dbo.covid_deaths
WHERE location = 'Australia'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows the percentage of population who got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as infectionPercentage
FROM PortfolioProject.dbo.covid_deaths
--WHERE location = 'Australia'
ORDER BY 1,2


-- Countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as infectionPercentage
FROM PortfolioProject.dbo.covid_deaths
GROUP BY location, population
ORDER BY infectionPercentage DESC


-- Countries with highest death rates compared to population
SELECT location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


-- Continents with highest death rates compared to population (BREAK BY CONTINENT)
SELECT continent, SUM(cast(new_deaths as int)) as totalDeathCount
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as deathPercentage
FROM PortfolioProject.dbo.covid_deaths
WHERE continent IS NOT NULL


-- Joining deaths and vaccinations tables
-- Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USING CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations,rollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)

SELECT *, (rollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
rollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (rollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rollingPeopleVaccinated
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated
