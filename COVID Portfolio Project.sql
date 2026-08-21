-- Retrieve all columns from CovidDeaths table 
-- and sort the results first by location, then by date

SELECT *          
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

-- Retrieve selected Covid data by location and date,
-- including cases, deaths, and population

SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM PortfolioProject..CovidDeaths 
ORDER BY location, date;

-- Calculate the likelihood of dying from COVID-19 in the United States
-- DeathPercentage = (total_deaths/total_cases)*100

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY location, date;

-- Calculate what percentage of the population contracted COVID-19
-- in the United States over time
-- covid_case_percentage = (total_cases/population)*100

SELECT 
    location,
    date,
    population, 
    total_cases, 
    (total_cases/population)*100 AS covid_case_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY location, date;

-- Find countries with the highest COVID-19 infection rate compared to their population
-- percent_population_infected = (highest total_cases/population)*100

SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY percent_population_infected DESC

-- Show countries with the highest COVID-19 death count relative to population
-- Excludes rows where continent is not null (e.g., aggregated regions)

SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY 
    continent
ORDER BY 
    highest_death_count DESC;

-- Show continents with the total COVID-19 death count
-- Excludes rows where continent is  not null

SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;


-- Calculate global totals for cases and deaths, computes death percentage,

Select
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null;

-- Retrieve all columns from CovidVaccinations table 
-- and sort the results first by location, then by date

SELECT * 
FROM PortfolioProject..CovidVaccinationsData
ORDER BY location, date;

-- Join Covid deaths and vaccination data
-- Calculate cumulative vaccinations per country over time

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location 
              ORDER BY dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinationsData AS vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Create a CTE to calculate rolling vaccination numbers per location

WITH PopvsVac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) 
            OVER (
                PARTITION BY dea.location 
                ORDER BY dea.date
            ) AS rolling_people_vaccinated
    FROM PortfolioProject..CovidDeaths AS dea
    JOIN PortfolioProject..CovidVaccinationsData AS vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

Select *,(rolling_people_vaccinated/population)*100 AS vaccintion_percentage
From PopvsVac;

-- Create a temporary table to store rolling vaccination numbers per location
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    NewVaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Populate the temporary table with rolling vaccination data

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER (
            PARTITION BY dea.location 
            ORDER BY dea.date, dea.location
        ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinationsData AS vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Select *, (RollingPeopleVaccinated / population) * 100 AS vaccintion_percentage
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualization

DROP VIEW IF EXISTS PercentPopulationVaccinated;
Go

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) 
        OVER(PARTITION BY dea.location 
             ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinationsData vac
        ON dea.location = vac.location
        AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

Select * From PercentPopulationVaccinated;




