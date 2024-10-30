SELECT 
	location,date,total_cases,new_cases,total_deaths,population
FROM 
	coviddeaths
ORDER BY 1,2;

-- Looking for total cases vs total deaths -- 
-- Shows likelihood of dying if you contract covid in you country --

SELECT 
	location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM 
	coviddeaths
WHERE location = 'Saudi Arabia' 
ORDER BY 4 DESC;

-- Looking at total cases vs population -- 
-- Shows what percentage of population got covid -- 

SELECT 
	location,date, population,total_cases, (total_cases/population)*100 AS cases_percentage
FROM 
	coviddeaths
WHERE location = 'Saudi Arabia' 
ORDER BY 1,2;

-- Looking at countries with with highest infection rate compared to population -- 

SELECT 
	location,
	population,
	MAX(total_cases) AS highest_infected,
	MAX((total_cases/population))*100 AS percentage_infected
FROM 
	coviddeaths
GROUP BY 
 	location,population
ORDER BY percentage_infected DESC;

-- Showing countries with highset death count per population -- 

SELECT 
	location,
	MAX(total_deaths) AS TotalDeathCount
FROM 
	coviddeaths
WHERE 
	 continent IS NOT NULL
GROUP BY 
 	location
ORDER BY TotalDeathCount DESC;

-- Showing continent with highset death count per population --

SELECT 
	continent, MAX(total_deaths) AS TotalDeathCount
FROM 
	coviddeaths
GROUP BY 
 	continent
ORDER BY TotalDeathCount DESC;

-- Global numbers --

SELECT 
	date, 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) AS death_percentage
FROM 
	coviddeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	date
ORDER BY 
	date, total_cases;

-- Looking at total population vs vaccination --

SELECT 
	de.continent, de.location, de.date, de.population, vc.new_vaccinations,
	SUM(CAST(vc.new_vaccinations AS INT))
	OVER(PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPV
FROM coviddeaths AS de
JOIN covidvaccination AS vc 
	ON de.location = vc.location 
	AND de.date = vc.date
WHERE 
	de.continent IS NOT NULL
ORDER BY 
	2,3;

-- Expanding the last point with cte -- 

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPV)
AS 
(
SELECT 
	de.continent, de.location, de.date, de.population, vc.new_vaccinations,
	SUM(CAST(vc.new_vaccinations AS INT))
	OVER(PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPV
FROM coviddeaths AS de
JOIN covidvaccination AS vc 
	ON de.location = vc.location 
	AND de.date = vc.date
WHERE 
	de.continent IS NOT NULL
)
SELECT *,
	(RollingPV/population)*100 AS TotalVacOVERpop
FROM
	PopvsVac;


-- Creating view --

CREATE VIEW PopvsVac AS 
SELECT 
	de.continent, de.location, de.date, de.population, vc.new_vaccinations,
	SUM(CAST(vc.new_vaccinations AS INT))
	OVER(PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPV
FROM coviddeaths AS de
JOIN covidvaccination AS vc 
	ON de.location = vc.location 
	AND de.date = vc.date
WHERE 
	de.continent IS NOT NULL


SELECT * FROM popvsvac;
