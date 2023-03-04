SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 


SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 

--Showing percentage of population infected each day for the United States 
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL 

--Showing percentage of population infected for each location 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC 


--Showing the total death count for each location   
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC 


--Showing total death count for each continent including global total 
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

--Showing total death count for the 3 largest countries in North America 
SELECT TOP 3 location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = 'North America'
GROUP BY location, population 
ORDER BY TotalDeathCount DESC 

--global totals for cases, deaths, and likelihood of dying from infection 
SELECT SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 

--total cases and deaths by day globally  
SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date 
ORDER BY date 

SELECT * 
FROM PortfolioProject..CovidVaccinations

-- total people vaccinated by location  
SELECT location, SUM(CONVERT(int, new_vaccinations)) TotalPeopleVaccinated  
FROM PortfolioProject..CovidVaccinations 
WHERE continent is not null 
GROUP BY location 
ORDER BY TotalPeopleVaccinated DESC 

--rolling amount of people vaccinated by location  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY dea.location, dea.date 

--total new vaccinations and percentage of population vaccinated by location 
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

CREATE View PopVsVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT * 
FROM PopVsVac

--total new vaccinations and percentage of population vaccinated in North America by country 
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

CREATE View PercentPopulationVaccinatedNA as 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent = 'North America'
 
 SELECT * 
 FROM PercentPopulationVaccinatedNA
