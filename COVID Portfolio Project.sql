/*
COVID-19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null


SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 


--Total Cases, Total Deaths, & likelihood of dying if infected in the United States 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent is not null 


--Total Cases & percentage of population infected based on country  
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null  
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC 


--Countries with highest death count 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC 


--Total death count for each continent including global total 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY location 
ORDER BY TotalDeathCount DESC 
 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount desc


--Total death count for the 3 largest countries in North America 
SELECT TOP 3 location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = 'North America'
GROUP BY location, population 
ORDER BY TotalDeathCount DESC 


--Global totals for cases, deaths, and likelihood of dying from infection 
SELECT SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 


--Global totals for cases and deaths by day 
SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date 
ORDER BY date 


SELECT * 
FROM PortfolioProject..CovidVaccinations


--Total people vaccinated by location  
SELECT location, SUM(CONVERT(int, new_vaccinations)) TotalPeopleVaccinated  
FROM PortfolioProject..CovidVaccinations 
WHERE continent is not null 
GROUP BY location 
ORDER BY TotalPeopleVaccinated DESC 


--Total population, vaccinations, & amount of population vaccinated  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY dea.location, dea.date 


--Using CTE to calculate percent of population vaccinated 
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT * , (RollingPeopleVaccinated/population)*100 PercentVaccinated 
FROM PopVsVac 


--View stored for future visualizations 
CREATE View PopVsVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT * 
FROM PopVsVac


--Using Temp Table to calculate percentage of population vaccinated in North America  
DROP TABLE if exists #PercentPopulationVaccinatedNA
CREATE TABLE #PercentPopulationVaccinatedNA
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinatedNA
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date  
WHERE dea.continent = 'North America'

SELECT * , (RollingPeopleVaccinated/population)*100 PercentVaccinated
FROM #PercentPopulationVaccinatedNA 


--View stored for future visualizations 
CREATE View PercentPopulationVaccinatedNA as 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent = 'North America'
 
SELECT * 
FROM PercentPopulationVaccinatedNA
