Select *
From Covid19Death..covidDeaths
order by 3, 4

Select *
From Covid19Death..CovidVaccinations1
order by 3, 4


--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Covid19Death..covidDeaths
order by 1, 2

--Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19Death..covidDeaths
where location like '%states%'
order by 1, 2

--Looking at total cases vs population
Select location, date, total_cases, (total_cases/population)*100 as InfectionPercentage
From Covid19Death..covidDeaths
order by 1, 2

--Looking at countries with highest infection rate 
Select location, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectionPercentage
From Covid19Death..covidDeaths
Group by location, population
order by InfectionPercentage desc

--Breaking things down by continent

--Looking at continents with highest death count per population 
Select continent, Max(total_deaths) as TotalDeathCount
From Covid19Death..covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



--Looking at death percentage per day
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From Covid19Death..covidDeaths
where continent is not null
--Group by date
order by 1, 2

-- Total Population vs Vaccinations
-- Shows population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date) as totalVaccinations
From Covid19Death..covidDeaths dea
Join Covid19Death..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Shows percentage of population that has recieved at least one Covid Vaccine
-- Use CTE

with PopvsVac(continent, location, date, population, new_vaccinations, totalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date) as totalVaccinations
From Covid19Death..covidDeaths dea
Join Covid19Death..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (totalVaccinations/population)*100 as PercentageVac
From PopvsVac
order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
totalVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date) as totalVaccinations
From Covid19Death..covidDeaths dea
Join Covid19Death..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (totalVaccinations/population)*100 as PercentageVac
From #PercentPopulationVaccinated
order by 2,3

-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated
USE Covid19Death

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date) as totalVaccinations
From Covid19Death..covidDeaths dea
Join Covid19Death..CovidVaccinations1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated