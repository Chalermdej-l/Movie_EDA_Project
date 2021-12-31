select *
from PortfolioProject.dbo.CovidDeaths
where location like 'High income'


--Total Covid Case and Death Per population of each Country
select location,
isnull(max(total_cases),0) as TotalCase,
isnull(max(convert(int,total_deaths)),0) as TotalDeath,
population as Population ,
isnull(format((max(total_cases) / max(population) *100),'#.##'),0) as CasePerPopulation,
isnull(format((max(convert(int,total_deaths)) / max(population) *100),'#.##'),0) as DeathPerPopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null
and population is not null
group by location,population
order by location

--Country with the most death per covidcase
select location,
isnull(max(total_cases),0) as TotalCase,
isnull(max(cast(total_deaths as int)),0) as TotalDeath,
isnull(format((max(cast(total_deaths as int)) / max(total_cases) *100),'#.####'),0) as DeathPerCovidCases
from PortfolioProject.dbo.CovidDeaths
where continent is not null
and total_deaths is not null
and population is not null
group by location
order by 4 desc

--Country with the most Covid Cases Per Population
select location,
population as Population,
max(total_cases) as TotalCase,
(max(total_cases) / max(population) *100) as CasePerPopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null
and population is not null
and total_cases is not null
group by location,population
order by CasePerPopulation desc

--Covid Case and Death per continent and World
select 
location,
population as Population,
sum(new_cases) as TotalCases,
isnull(max(cast(total_deaths as int)),0) as TotalDeath,
format((sum(new_cases) /max(population))*100,'#.##') as ContinentCasePerPopulation,
isnull(format((max(cast(total_deaths as int)) / max(total_cases) *100),'#.####'),0) as DeathPerCovidCases
from PortfolioProject.dbo.CovidDeaths 
where continent is null
and not (location = 'Low income' 
or location = 'International'
or location ='Upper middle income' 
or location ='Lower middle income'
or location ='European Union'
or location ='High income')
group by location ,population
order by 1

--Covid Case per Income
select 
location,
population as Population,
sum(new_cases) as TotalCases,
format((sum(new_cases) /max(population))*100,'#.##') as ContinentCasePerPopulation
from PortfolioProject.dbo.CovidDeaths 
where continent is null
and location like'High income'
or location like'Upper middle income' 
or location like'Lower middle income'
or location like'Low income'
group by location ,population
order by 1


--New Covid Case report by Date and Percent per population for Thailand 
select location,
date,
population,
sum(new_cases) over (partition by location order by date) as 'TotalCaseToDate',
format((sum(new_cases) over (partition by location order by date) / population)*100,'#.#######') as 'CasePerPopulation'
from PortfolioProject.dbo.CovidDeaths
where continent is not null
and new_cases is not null
and location like '%thai%' --Change contry here
and population is not null
order by date

--Join Vaccination information
select *
from CovidDeaths dea
inner join CovidVaccination vac
on dea.date = vac.date

--Vaccination per country by Date and Per Population
--Use CTE
with CombineData_Vac (Continent,Date,Location,Population,NewVaccination,TotalVaccinationSofar)
AS
(
select 
vac.continent,
vac.date,
vac.location,
dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by vac.location order by vac.location,vac.date) as VaccinationSofar
from PortfolioProject.dbo.CovidDeaths dea
inner join PortfolioProject.dbo.CovidVaccination vac
on	dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
)
select Location,Date,Population,NewVaccination,TotalVaccinationSofar,
(TotalVaccinationSofar/Population)*100 as TotalVacandboosSofar
from CombineData_Vac
where NewVaccination is not null
-- and location like '%thai%' -- Uncomment for Country specific data
order by 1 , 2


--Total Vaccination each coutnry per population
--Use TempTable
drop table if exists #VaccinationPerCountry
create table #VaccinationPerCountry 
(
continent nvarchar(255),
Date datetime,
Location nvarchar(255),
Population numeric,
FullyVac bigint
)
insert into #VaccinationPerCountry
select 
vac.continent,
vac.date,
vac.location,
dea.population,
convert(bigint,vac.people_fully_vaccinated) as Fullyvac
from PortfolioProject.dbo.CovidDeaths dea
inner join PortfolioProject.dbo.CovidVaccination vac
on	dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
and population is not null
select location,
Population,
isnull(max(FullyVac),0) As FullyVaccinated,
isnull((max(FullyVac)/Population)*100,0) as VacPerPopulation
from #VaccinationPerCountry
group by location,Population
order by 1 

--Create View for further visualization
create view VaccinatePerCountry as
select 
vac.continent,
vac.date,
vac.location,
dea.population,
convert(bigint,vac.people_fully_vaccinated) as Fullyvac
from PortfolioProject.dbo.CovidDeaths dea
inner join PortfolioProject.dbo.CovidVaccination vac
on	dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
and population is not null

create view CasePerIncome as 
select 
location,
population as Population,
sum(new_cases) as TotalCases,
format((sum(new_cases) /max(population))*100,'#.##') as ContinentCasePerPopulation
from PortfolioProject.dbo.CovidDeaths 
where continent is null
and location like'High income'
or location like'Upper middle income' 
or location like'Lower middle income'
or location like'Low income'
group by location ,population

create view CasePercontinent as
select 
location,
population as Population,
sum(new_cases) as TotalCases,
isnull(max(cast(total_deaths as int)),0) as TotalDeath,
format((sum(new_cases) /max(population))*100,'#.##') as ContinentCasePerPopulation,
isnull(format((max(cast(total_deaths as int)) / max(total_cases) *100),'#.####'),0) as DeathPerCovidCases
from PortfolioProject.dbo.CovidDeaths 
where continent is null
and not (location = 'Low income' 
or location = 'International'
or location ='Upper middle income' 
or location ='Lower middle income'
or location ='European Union'
or location ='High income')
group by location ,population

create view TotalCaseDeathPercountry as
select location,
population as Population,
max(total_cases) as TotalCase,
(max(total_cases) / max(population) *100) as CasePerPopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null
and population is not null
and total_cases is not null
group by location,population





