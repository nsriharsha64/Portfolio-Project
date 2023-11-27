Select *
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null

--Select *
--From [Portfolio Project (1)].dbo.['Covid Vaccinations$']

--Select data that we are goimg to use
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From [Portfolio Project (1)].dbo.CovidDeaths$
order by 1,2

--Looking at countries with High infection rate compared to population
Select location, population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as HighInfectionPercentage
From [Portfolio Project (1)].dbo.CovidDeaths$
group by location, population
order by HighInfectionPercentage desc

--Showing countries with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Shoing continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project (1)].dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, ['Covid Vaccinations$'].new_vaccinations, SUM(cast(['Covid Vaccinations$'].new_vaccinations as int)) over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 
From [Portfolio Project (1)].dbo.CovidDeaths$
Join [Portfolio Project (1)].dbo.['Covid Vaccinations$']
On CovidDeaths$.location = ['Covid Vaccinations$'].location
and CovidDeaths$.date = ['Covid Vaccinations$'].date
where CovidDeaths$.continent is not null
order by 2,3

--Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)as
(
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, ['Covid Vaccinations$'].new_vaccinations, SUM(cast(['Covid Vaccinations$'].new_vaccinations as int)) over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingPeopleVaccinated 
From [Portfolio Project (1)].dbo.CovidDeaths$
Join [Portfolio Project (1)].dbo.['Covid Vaccinations$']
On CovidDeaths$.location = ['Covid Vaccinations$'].location
and CovidDeaths$.date = ['Covid Vaccinations$'].date
where CovidDeaths$.continent is not null
)
Select *, (RollingPeopleVaccinated/new_vaccinations)*100
From popvsvac

--TEMP TABLE
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, ['Covid Vaccinations$'].new_vaccinations, SUM(cast(['Covid Vaccinations$'].new_vaccinations as int)) over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingPeopleVaccinated 
From [Portfolio Project (1)].dbo.CovidDeaths$
Join [Portfolio Project (1)].dbo.['Covid Vaccinations$']
On CovidDeaths$.location = ['Covid Vaccinations$'].location
and CovidDeaths$.date = ['Covid Vaccinations$'].date
where CovidDeaths$.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Crearing view to store the data for later visualization
Create view PercentPopulationVaccinated as
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, ['Covid Vaccinations$'].new_vaccinations, SUM(cast(['Covid Vaccinations$'].new_vaccinations as int)) over (partition by CovidDeaths$.location order by CovidDeaths$.location, CovidDeaths$.date) as RollingPeopleVaccinated
From [Portfolio Project (1)].dbo.CovidDeaths$
Join [Portfolio Project (1)].dbo.['Covid Vaccinations$']
On CovidDeaths$.location = ['Covid Vaccinations$'].location
and CovidDeaths$.date = ['Covid Vaccinations$'].date
where CovidDeaths$.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
