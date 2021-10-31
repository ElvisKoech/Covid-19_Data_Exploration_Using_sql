Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4
--selecting the columns to use
Select location, date,total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2
--Checking for total Cases vs Total Deaths
-- likelihood of dying if you contact covid in your country
Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From PortfolioProject..CovidDeaths
where location like '%Kenya%'
and continent is not null
order by 1,2

--checking for total Cases vs Population
-- shows what percentage of population got Covid-19
Select location, date, population,total_cases,(total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
order by 1,2

--Checking for Countries with Higest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as InfectionRateperCountry
From PortfolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
Group by location,population
order by InfectionRateperCountry desc

--Showing Countries with Higest Death Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Showing DeathCountperContinent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityRate
From PortfolioProject..CovidDeaths
--where location like '%Kenya%'
where continent is not null
order by 1,2

--Looking at Total population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with popvsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From popvsVac

--Temp Table
Drop Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/population)*100
From #PercentpopulationVaccinated


--Creating view to store data for later visualization
Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentpopulationVaccinated
