/*

Explore Data for Covid information as of 25-12-2021
Information from : https://ourworldindata.org/explorers/coronavirus-data-explorer

*/

select *
from PortfolioProject.dbo.CovidDeaths
where location like 'High income'


--Total Covid Case and Death Per population of each Country
--Show how many covid case and death for each country and their population

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
--Percentage chance of dying for each country if infected with Covid

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
--Show country with the most case per their population

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
--Show how many Cases and Death for each continent and the world
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
--What percentage of Covid in each income bracket

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
--Show Covid case by date for Thailand and the percentage of infected per population each day

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
--Show Vaccination rate per day by each country per their population. Using CTE to performe calculation on previous query

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
--What percentage of FullyVaccinate per population for each country. Use TempTable for calculation on previuos query
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


--Create View to store table and for further visualization
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





