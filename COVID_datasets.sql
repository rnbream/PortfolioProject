SELECT 
	location_loc, 
	case_date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM 
	CovidDeaths
ORDER BY 
	1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT 
	location_loc, 
	case_date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM 
	CovidDeaths
WHERE 
	location_loc ILIKE '%states%'
ORDER BY 
	1,2

-- looking at total cases vs population
-- shows what percentage of population got COVID
SELECT 
	location_loc, 
	case_date, 
	total_cases, 
	total_deaths, 
	population, 
	(total_cases/population)*100 AS percent_population_infected
FROM 
	CovidDeaths
--WHERE location_loc = 'Philippines'
ORDER BY 
	death_percentage DESC

-- looking at countries with highest infection rate compared to population
SELECT 
	location_loc, 
	population,
	MAX(total_cases) AS highest_infection_count, 
	MAX((total_cases/population))*100 AS percent_population_infected
FROM 
	CovidDeaths
-- WHERE 
-- 	location_loc = 'Philippines'
GROUP BY 
	location_loc, population
ORDER BY 
	percent_population_infected DESC

-- showing countries with the highest death count per population
SELECT 
	location_loc,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM 
	CovidDeaths
GROUP BY
	location_loc
ORDER BY 
	total_death_count DESC
	
--let's break things down by continent 
SELECT 
	location_loc,
	MAX(total_deaths) AS total_death_count
FROM 
	CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	location_loc
ORDER BY 
	total_death_count DESC

--showing continents with the highest death count per population
SELECT 
	continent,
	population,
	MAX(total_deaths) AS highest_death_count
FROM 
	CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 
	continent, population
ORDER BY
	highest_death_count DESC
	
-- global numbers
SELECT 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM 
	CovidDeaths
-- GROUP BY
-- 	case_date
ORDER BY 
	1,2

-- looking at total population vs vaccinations
SELECT 
	dea.continent, 
	dea.location_loc, 
	dea.case_date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location_loc ORDER BY dea.location_loc, dea.case_date) AS rolling_people_vaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
	ON dea.location_loc = vac.location_loc
	AND dea.case_date = vac.case_date
WHERE 
	dea.continent IS NOT NULL
ORDER BY 
	2,3
	
-- use CTE
WITH PopsVsVac (continent, location_loc, case_date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location_loc, 
	dea.case_date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location_loc ORDER BY dea.location_loc, dea.case_date) AS rolling_people_vaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
	ON dea.location_loc = vac.location_loc
	AND dea.case_date = vac.case_date
WHERE 
	dea.continent IS NOT NULL
-- ORDER BY 
-- 	2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopsVsVac

-- creating view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location_loc, 
	dea.case_date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location_loc ORDER BY dea.location_loc, dea.case_date) AS rolling_people_vaccinated
FROM 
	CovidDeaths AS dea
JOIN 
	CovidVaccinations AS vac
	ON dea.location_loc = vac.location_loc
	AND dea.case_date = vac.case_date
WHERE 
	dea.continent IS NOT NULL
-- ORDER BY 
-- 	2,3

SELECT * 
FROM 
	PercentPopulationVaccinated







	


