SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent = 'africa'
ORDER BY location, date


/* Selection of data that we will use for our exploration.
	The different information I need
	Location: Name of the country
	Date: the date x
	Total_cases: Total number of infections at date x
	New_cases: New infections at date x
	Total_deaths: Total number of deaths at date x
	Population: Population
*/

SELECT location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

/*  See the total number of deaths (total_deaths) compared to the total number of cases (total_cases)
This query shows the probability of death if you contract covid-19 in your country.
*/

SELECT location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%' 
WHERE continent is not null
ORDER BY 1,2


/* See the total number of infections (total_cases) compared to the population (population).
This query shows what percentage of the population has contracted the covid.
*/

SELECT location,
	   date,
	   total_cases,
	   population,
	   (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
ORDER BY 1,2

SELECT location,
	   date,
	   total_cases
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
ORDER BY 1,2


-- See which continent has the highest infection rate compared to its population. 

SELECT location,
	   MAX(total_cases) AS HighestInfectionCount,
	   MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is null AND location IN ('Europe', 'North America', 'South America',
										 'Oceania', 'Asia', 'Africa')
GROUP BY location
ORDER BY PercentPopulationInfected DESC
 
-- Show country with the Highest death percentage

SELECT location,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- SEE NUMBERS BY CONTINENT
-- See the continent with the highest death rates

SELECT continent,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC


SELECT location,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is null AND location IN ('Europe', 'North America', 'South America',
										 'Oceania', 'Asia', 'Africa')
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases,
	   SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%' 
WHERE continent is not null
ORDER BY 1,2


-- Exploring the CovidVaccinations table
-- We will join the two tables (CovidDeaths and CovidVaccinations)

-- See the overall percentage of population vaccinated

SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Create a temporary table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

/* Create Views to save data for later viewing 
with a visualization tool (Tableau or Power BI)
*/

-- 1

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


--2
CREATE VIEW GlobalNumber AS
SELECT SUM(new_cases) AS TotalCases,
	   SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%' 
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--3
CREATE VIEW TotalDeathByContinent AS
SELECT SUM(new_cases) AS TotalCases,
	   SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%' 
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2


--4
CREATE VIEW TotalDeathByCountry AS
SELECT location,
	   MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathsCount DESC


--5
CREATE VIEW PercentInfectionOverPopuplationByContinent AS
SELECT location,
	   MAX(total_cases) AS HighestInfectionCount,
	   population,
	   MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is null
GROUP BY population, location
--ORDER BY PercentPopulationInfected DESC


--6
CREATE VIEW PercentPopulationInfectedByCountry AS
SELECT location,
	   date,
	   total_cases,
	   population,
	   (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%'
WHERE continent is not null
--ORDER BY 1,2


--7
CREATE VIEW DeathProbabilityByCountry AS
SELECT location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Chad%' 
WHERE continent is not null
--ORDER BY 1,2