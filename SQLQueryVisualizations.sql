select cd.Location,cd.date,cd.total_cases,cd.new_cases,cd.total_deaths,cd.population
from coviddeaths cd
order by 1,2

--Looking at the totaldeath by total cases as death percentage
select cd.Location,cd.date,cd.total_cases,cd.new_cases,cd.total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths cd
where cd.location like '%states%'
order by 1,2

-- looking total cases by population 
select cd.Location,cd.date,cd.population,cd.total_cases,(cd.total_cases/cd.population)*100 as PercentPopulationInfected
from coviddeaths cd
where cd.location like '%states%'
order by 1,2

--Looking at countries with highest infected rate compared to population
select cd.Location,cd.population,Max(cd.total_cases) as Maxcase,max((cd.total_cases/cd.population))*100 as PercentPopulationInfected
from coviddeaths cd
group by cd.[location],cd.population
order by PercentPopulationInfected desc

--Showing Countries with highest death count by population

select cd.Location, Max(Cast(cd.total_deaths as Int)) as TotalDeathCount
from CovidDeaths cd
group by cd.[location]
order by TotalDeathCount desc

--Let's Break Things by location
select cd.[location], Max(Cast(cd.total_deaths as Int)) as TotalDeathCount
from CovidDeaths cd
where cd.continent is NOT NULL
group by cd.[location]
order by TotalDeathCount desc

--Let's break things by Continent
select cd.[continent], Max(Cast(cd.total_deaths as Int)) as TotalDeathCount
from CovidDeaths cd
where cd.continent is NOT NULL
group by cd.[continent]
order by TotalDeathCount desc

--Global Numbers
  select cd.date, SUM(cd.new_cases) as TotalCase,SUM(cd.new_deaths) as TotalDeath, SUM(cd.new_deaths)/SUM(cd.new_cases)*100 as DeathPercentage
 from CovidDeaths cd
 where cd.continent is not null
 and cd.new_cases !=0
 and cd.new_deaths !=0
 group by cd.date 
 order by 1,2


select cd.date,cd.new_cases, cd.new_deaths
from coviddeaths Cd 
where cd.date = '2020-01-05'

--Looking at Total Population vs vaccinations
select dea.continent, dea.location , dea.date, dea.population,vac.new_vaccinations,
 sum(vac.new_vaccinations)
 OVER (partition by dea.location order by dea.location
,dea.date) as RollingPopulationVaccinated
from CovidDeaths dea 
join covidvaccinations VAc 
on dea.location = vac.LOCATION
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPopulationVaccinated)
AS
(select dea.continent, dea.location , dea.date, dea.population,vac.new_vaccinations,
 sum(vac.new_vaccinations)
 OVER (partition by dea.location order by dea.location
,dea.date) as RollingPopulationVaccinated
from CovidDeaths dea 
join covidvaccinations VAc 
on dea.location = vac.LOCATION
and dea.date = vac.date 
where dea.continent is not null)

Select * ,(RollingPopulationVaccinated/Population)*100 
from PopvsVac

-- Use Temp Table
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(Continent Varchar(255),
Location Varchar(255),
Date datetime,
Population Numeric,
new_vaccinations Numeric,
RollingPopulationVaccinated Numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPopulationVaccinated
from coviddeaths DEA 
join covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.DATE

Select * , (RollingPopulationVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view table for Visualizations
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPopulationVaccinated
from coviddeaths DEA 
join covidvaccinations vac 
on dea.location = vac.location 
and dea.date = vac.DATE



