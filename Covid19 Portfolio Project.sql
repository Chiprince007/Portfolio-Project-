
select Location, date,new_cases,total_deaths,population
from [Portfolio Project]..[covid-deaths]
order by 1,2

--TOTAL CASES VS TOTAL DEATHS

select Location, date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 FatalityRate
from [Portfolio Project]..[covid-deaths]
where location like '%geria'
order by 1,2
	
--- TOTAL CASES VS POPULATION - INFECTION RATE
select Location, date,total_cases,population,(total_cases/population)*100 InfectionRate
from [Portfolio Project]..[covid-deaths]
--where location like '%geria'
order by 1,2


--COUNTRIES WITH THE HIGHEST INFECTION RATE
select Location,population,max(total_cases)HighestInfectionCount,Max((total_cases/population))*100 InfectionRate
from [Portfolio Project]..[covid-deaths]
--where location like '%geria'
group by location, population
order by InfectionRate desc


--- HIGHEST DEATH COUNT PER POPULATION
select location,max(cast(total_deaths as int)) TotalDeathCount
from [Portfolio Project]..[covid-deaths]
where continent is not null
group by location
order by TotalDeathCount desc

---- CONTINENTS
select location,max(cast(total_deaths as int)) TotalDeathCount
from [Portfolio Project]..[covid-deaths]
where continent is null
group by location
order by TotalDeathCount desc

----- GLOBAL NUMBERS 
select sum(cast(new_cases as int)) TotalCases,sum(cast(new_deaths as int)) TotalDeath,(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 DeathPercentage --total_deaths,(cast(total_deaths as int)/total_cases)*100 DeathPercentage
from [Portfolio Project]..[covid-deaths]
where continent is not null
--group by date
order by 1,2

--- USING JOINS
select cvd.continent,cvd.location,cvd.date,cvd.population,cvv.new_vaccinations
,sum(cast (cvv.new_vaccinations as float)) over (partition by cvd.location order by cvd.location,cvd.date) RollingVaccination
from [Portfolio Project]..[covid-deaths] cvd
join [Portfolio Project]..[covid vaccination] cvv
	on cvd.location=cvv.location
	and cvd.date=cvv.date
where cvd.continent is not null
order by 2,3

--- USING CTEs
WITH POPVAC (continent,location,date,population,new_vaccinations,RollingVaccination)
as
(
select cvd.continent,cvd.location,cvd.date,cvd.population,cvv.new_vaccinations
,sum(cast (cvv.new_vaccinations as float)) over (partition by cvd.location order by cvd.location,cvd.date) RollingVaccination
from [Portfolio Project]..[covid-deaths] cvd
join [Portfolio Project]..[covid vaccination] cvv
	on cvd.location=cvv.location
	and cvd.date=cvv.date
where cvd.continent is not null
--order by 2,3
)
select *, (RollingVaccination/population)*100 PercentPopulationVaccinated
from POPVAC

---- TEMPTABLE

CREATE table #percentpopulationvaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric
)

insert into #percentpopulationvaccinated
select cvd.continent,cvd.location,cvd.date,cvd.population,cvv.new_vaccinations
,sum(cast (cvv.new_vaccinations as float)) over (partition by cvd.location order by cvd.location,cvd.date) RollingVaccination
from [Portfolio Project]..[covid-deaths] cvd 
join [Portfolio Project]..[covid vaccination] cvv
	on cvd.location=cvv.location
	and cvd.date=cvv.date
where cvd.continent is not null
--order by 2,3

select *, (RollingVaccination/population)*100 PercentPopulationVaccinated
from #percentpopulationvaccinated


--- CREATING VIEW FOR VISUALIZATION

create view populationvaccinated as
select cvd.continent,cvd.location,cvd.date,cvd.population,cvv.new_vaccinations
,sum(cast (cvv.new_vaccinations as float)) over (partition by cvd.location order by cvd.location,cvd.date) RollingVaccination
from [Portfolio Project]..[covid-deaths] cvd 
join [Portfolio Project]..[covid vaccination] cvv
	on cvd.location=cvv.location
	and cvd.date=cvv.date
where cvd.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinate
