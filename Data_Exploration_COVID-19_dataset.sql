--COVID 19 DATA EXPLORATION
--USING:JOINS,CTE'S,TEMPORARY TABLES,WINDOWS FUNCTIONS,AGGREGATE FUNCTIONS,VIEWS,DATA TYPE CONVERSION




SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT THE DATA WE ARE USING

SELECT Location,Date,Total_cases,new_cases,total_deaths,population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2;

--Looking at the total cases vs total deaths
--Shows the likelihood of dying if you contract covid in Haiti


SELECT Location,Date,Total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location='Haiti';
ORDER BY 1,2;

--Looking at the total cases vs Population
--Shows what percentage of the poulation got covid

SELECT Location,Date,population,Total_cases,(total_cases/population)*100 AS InfectionRate
FROM PortfolioProjects..CovidDeaths
WHERE location ='Haiti'
ORDER BY 1,2;

--The countries with highest infection rate compared to population

SELECT Location,population,MAX(Total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with highest Death Count per Population

SELECT Location,MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--BREAKING DATA EXPLORATION BY CONTINENT

--Showing Continents with highest Death Count per Population

SELECT continent,MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

CREATE VIEW TotalDeathCountPerContinent AS
SELECT continent,MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--WHERE location ='Haiti'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC;




--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases,SUM(cast (new_deaths AS INT)) AS Total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT Date,SUM(new_cases) AS Total_cases,SUM(cast (new_deaths AS INT)) AS Total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


--COVID VACCINATIONS
SELECT*
FROM PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date;

--Looking at Total Population vs Vaccinations
--Shows the percentage of the population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
    ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Using a Common Table Expression to perform Calculation on Partition By in previous query

WITH POPvsVAC(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
    ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3);
)
SELECT*,(RollingPeopleVaccinated/population)*100
FROM POPvsVAC;



--Using a temporary table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentageOfPopulationvaccinated
CREATE TABLE #PercentageOfPopulationvaccinated
(
Continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentageOfPopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
    ON dea.location=vac.location
    AND dea.date=vac.date

SELECT*,(RollingPeopleVaccinated/population)*100
FROM #PercentageOfPopulationvaccinated;


--Creating View to store data later for visualization


CREATE VIEW PercentagePopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM  PortfolioProjects..CovidDeaths AS Dea
JOIN PortfolioProjects..CovidVaccinations AS Vac
    ON dea.location=vac.location
    AND dea.date=vac.date
where dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationvaccinated;



--QUERIES USED FOR TABLEAU PROJECT

*/

---1. 
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

---2.

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
AND location NOT IN ('World','European Union','International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

---3.

SELECT location,Population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC;

---4.

SELECT location,Population,date,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location,population,date
ORDER BY PercentPopulationInfected DESC;



Tutorial found on Google from Alex the data analyst. 
