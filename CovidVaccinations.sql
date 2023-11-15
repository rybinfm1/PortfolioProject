--Initial Data exploration

Select * 
From PortfolioProject1..CovidDeaths
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2

--Total cases vs total deaths
--Likelyhood of dying from covid based on the date and country
--

Select location, date, total_cases,total_deaths, (convert(float,total_deaths))/(convert(float,total_cases))*100 as death_percentage
From PortfolioProject1..CovidDeaths
--Where location like '%Aus%'
order by death_percentage DESC

Select location, date, Population, total_cases, (convert(float,total_cases))/(convert(float,Population))*100 as infection_percentage
From PortfolioProject1..CovidDeaths
--Where location like '%Aust%'
order by infection_percentage DESC

--Countries highest infection rate compared to population
--Ordered by highest infection rate

Select location, population, MAX(cast(total_cases as float)) as highest_infection, MAX((cast(total_cases as float))/(cast(Population as float)))*100 
	as highest_infection_percent
FROM PortfolioProject1..CovidDeaths
Where continent IS NOT null
Group by location, population
Order by highest_infection_percent DESC

--Country's highest death count per population
--Ordered by highest death count

Select location, MAX(convert(float,total_deaths)) as total_death_count
FROM PortfolioProject1..CovidDeaths
Where continent is not null
Group by location
Order by total_death_count DESC

--CONTINENTS

--Continents with highest death count by poulation
--Ordered by total death count

Select continent, MAX(convert(float, total_deaths)) as total_death_count
From PortfolioProject1..CovidDeaths
Where continent is not null /*if continent is null there is no data on indifidual countries in this dataset*/
Group by continent
order by total_death_count desc

-- GLOBAL NUMBERS
--	Total Cases, Total Deaths, Death percentage Globally

Select SUM(new_cases) as total_cases, SUM(convert(float,new_deaths)) as total_deaths, SUM(convert(float,new_deaths))/SUM(new_cases)*100 
as death_percentage
From PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations
--created rolling vaccination count to track new vaccinations and add to total
--Joined both tables to compare populations and new vaccinations

With PopvsVac(continent, location, date, population, new_vaccinations, rolling_vac_count)
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent like '%north%'
)
Select *, (rolling_vac_count/population)*100 as rolling_vac_percentage
From PopvsVac

--Temp Table
--Created a temp table for percent of population vaccinated 
	--grouped by location


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_vac_count numeric)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (rolling_vac_count/population)*100 as VaccinationPopulationRatio
From #PercentPopulationVaccinated

--Creating view for further visualizations
--Same query as temp table above
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vac_count
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null