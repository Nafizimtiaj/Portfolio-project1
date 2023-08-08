Select*
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4 

--Select*
--From PortfolioProject..CovidVaccinations$
--order by 3,4 

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercantage
From PortfolioProject..CovidDeaths$
Where location='canada' and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what parcentage of population got covid

Select Location, Date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths$
--Where location='canada'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, MAX (total_cases) as highestinfectioncount, MAX (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..CovidDeaths$
--Where location='canada'
Group by location, population
order by percentpopulationinfected desc

--Showing Countries with highest death count per population
Select Location, Max (Cast(Total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
--Where location='canada'
Where continent is not null
Group by location
order by Totaldeathcount desc

--Let's break things down by continent


--Showing continents with the hihgest death count per population

Select continent, Max (Cast(Total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths$
--Where location='canada'
Where continent is not null
Group by continent
order by Totaldeathcount desc

--Global Numbers

Select Sum (New_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum (New_cases)*100 as deathpercantage
From PortfolioProject..CovidDeaths$
--Where location='canada'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into	#PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 



--Creating View to store data for later visualization  

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated