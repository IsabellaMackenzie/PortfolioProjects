/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Aggregate Functions, Creating Views, Converting Data Types
This code was written for SQLite using DB Browser on a Mac.
*/

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths in Costa Rica
--Shows likelihood of dying if you contract oovid in Costa Rica


SELECT location, date, total_cases, total_deaths,  (total_deaths/total_cases) * 100  AS DeathPercentage
FROM CovidDeaths
WHERE location like 'Costa%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population were infected with Covid


SELECT location, date, population, total_cases,   (total_cases/population) * 100  AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like 'Costa%'
ORDER BY 1, 2


-- Looking at countries with Highest Infection Rate compared to Population


SELECT location,  population, MAX(total_cases) AS HighestInfectionCount,   Max((total_cases/population)) * 100  AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like 'Costa%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Shows Countries with Highest Death Count

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like 'Costa%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Breaking things down by continent

-- Shows continents with the highest death count

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like 'Costa%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global numbers

-- Shows Death Percentage per Day


SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Overall Death Percentage

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

)

SELECT * , (RollingPeopleVaccinated/population) * 100 AS PercentagePopulationVaccinated
FROM	PopvsVac




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

