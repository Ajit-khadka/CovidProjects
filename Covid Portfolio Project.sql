SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4

-- COVID DEATHS
--Selecting Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- total_cases vs total_deaths (Death percentage of covid patient in Nepal)
-- Typecasting total_cases total_deaths from nvarchar to decimal to find death percentage

SELECT location, date,total_cases ,total_deaths, (CAST(total_deaths as decimal) / CAST(total_cases as decimal))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location LIKE 'Nepal' AND  continent is NOT NULL
ORDER BY 1,2

--total_cases vs population (Percentage of people who got infected by covid)

SELECT location, date,total_cases ,population, (CAST(total_cases as decimal) / CAST(population as decimal))*100 AS InfectedPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location LIKE 'Nepal'
ORDER BY 1,2

--Highest infected rate per population in countries

SElECT location, population, MAX(CAST(total_cases as decimal)) as Highest_infected_Count, MAX((CAST(total_cases as decimal)/CAST(population as decimal)))*100 AS HighestInfectedPercentage
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY HighestInfectedPercentage DESC

--Highest dead count per population in different country and continent

SElECT location, population, MAX(total_deaths) as Highest_Death_Count
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Highest_Death_Count DESC

--For continent
--Data containing in continent column was not accurate

--SElECT continent, MAX(CAST(total_deaths as decimal)) as Highest_Death_Count
--FROM  PortfolioProject.dbo.CovidDeaths
--WHERE continent is not NULL
--GROUP BY continent
--ORDER BY Highest_Death_Count DESC

-- Location column also contained data of continents which where ~ accurate to present date (6/5/2023)

SElECT location, MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL AND location NOT LIKE '%income' AND Location <> 'European Union'
GROUP BY location
ORDER BY Highest_Death_Count DESC

--Global Timeline of Death percentage due to covid from past to present 

SELECT  date, SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL 
GROUP BY date
HAVING SUM(new_cases) <> 0
ORDER BY 1,2

--Global cases,death, Death percentage

SELECT  SUM(new_cases) AS total_cases , SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL 
--GROUP BY date
--HAVING SUM(new_cases) <> 0
ORDER BY 1,2

--COVID VACCINATIONS
--total population of a country vs Vaccinations 

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS decimal))
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS PeopleVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS CV
JOIN  PortfolioProject.dbo.CovidDeaths AS CD
ON CV.location = CD.location AND CV.date = CD.date
WHERE CD.continent is NOT NULL 
ORDER BY 2,3

--Using CTE
--Vaccinated Percentage

WITH PopvsVac(continent, location, date, population, new_vaccination, PeopleVaccinated)
AS
(SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS decimal))
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS PeopleVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS CV
JOIN  PortfolioProject.dbo.CovidDeaths AS CD
ON CV.location = CD.location AND CV.date = CD.date
WHERE CD.continent is NOT NULL 
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM PopvsVac
--WHERE location = 'Nepal'

--USING temp table
--299979

DROP TABLE IF EXISTS #VaccinatedPercentage
CREATE TABlE #VaccinatedPercentage
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
PeopleVaccinated numeric
)

INSERT INTO #VaccinatedPercentage
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS decimal))
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS PeopleVaccinated
FROM PortfolioProject..CovidVaccinations AS CV
JOIN  PortfolioProject..CovidDeaths AS CD
ON CV.location = CD.location AND CV.date = CD.date
WHERE CD.continent is NOT NULL 
ORDER BY 2,3

SELECT *, (PeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM #VaccinatedPercentage

-- Creating view for storing data for visualization

--DROP VIEW HighestDeathCount

CREATE VIEW PopulationVaccinationPercentage AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_vaccinations AS decimal))
OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS PeopleVaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS CV
JOIN PortfolioProject.dbo.CovidDeaths AS CD
     ON CV.location = CD.location AND CV.date = CD.date
WHERE CD.continent is NOT NULL 
--ORDER BY 2,3

CREATE VIEW HighestDeathCount AS
SElECT location, population, MAX(total_deaths) as Highest_Death_Count
FROM  PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
--ORDER BY Highest_Death_Count DESC

SELECT * FROM PopulationVaccinationPercentage