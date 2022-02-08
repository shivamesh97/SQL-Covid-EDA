--Liklihood of dying if you are covid positive covid
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as infectionFatalityRate
from covid..covid_deaths
where total_cases <> 0 and continent <> '0'
order by location, date

--liklihood of dying because of covid
select location, date, total_cases, total_deaths,population,(total_deaths/population)*100 as mortalityRate
from covid..covid_deaths
where total_cases <> 0  and continent<>'0'
order by location, date

--liklihood of getting covid
select location, date, total_cases,  total_deaths,new_deaths,population,(total_cases/population)*100 as infectionRate
from covid..covid_deaths
where total_cases <> 0 and continent<>'0' 
order by location, date

--Countries with highest infection rate
select location, max(total_cases) as TotalCases,population,max((total_cases/population)*100) as infectionRate
from covid..covid_deaths
where population<>0 and continent<>'0'
group by location, population
order by infectionRate desc 

--countries with highest mortality rate per population
select location, max(total_deaths) as TotalDeaths,population,max((total_deaths/population)*100) as mortalityRate
from covid..covid_deaths
where population<>0 and continent <>'0'
group by location, population
order by TotalDeaths desc 

--continients with highest mortality rates
create view continent_mortality_rate as
select continent, max(total_deaths) as TotalDeaths,max((total_deaths/population)*100) as mortalityRate
from covid..covid_deaths
where population<>0 and continent <>'0'
group by continent


--Global covid infection Rates by Date
select  date, sum(total_cases) as TotalCases,sum(total_deaths) as TotalDeaths, (sum(total_deaths)/sum(total_cases))*100 as deathsPerPatient
from covid..covid_deaths
where continent <>'0' and total_cases <>0
group by date
order by date


-- XXXXXXXXXXXXXXX BREAK  XXXXXXXXXXXX BREAK XXXXXXXXXXXXXXXXX

--Vaccination table


--Temp table 
create view vaccinated_population_percentage as
with popVSvac (continent, location, population, date, fully_vaccinated, boosters)
as
(
select 
	continent,
	location,
	population,
	cast(date as datetime) as date,
	cast(people_fully_vaccinated as bigint) as fully_vaccinated,
	cast(total_boosters as bigint) as boosters
	from covid..covid_vaccinations
)
select * , (fully_vaccinated/population)*100 as PopPercentVaccinated
from popVSvac
where continent <>'0'


--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

--Create table for countries with their gdp and pop Density
drop table if exists countryInfo
create table countryInfo(
	location nvarchar(255),
	date datetime,
	population bigint,
	cases float,
	deaths float,
	people_vaccinated float,
	gdp_per_capita float,
	population_density float
)

insert into countryInfo
	select 
		dea.location, 
		max(dea.date) as date, 
		max(dea.population),
		max(dea.total_cases) as Cases, 
		max(dea.total_deaths) as deaths, 
		max(cast(people_fully_vaccinated as bigint)) as people_vaccinated, 
		max(gdp_per_capita) as gdp_per_capita,
		max(vac.population_density) as population_density
	from covid..covid_deaths as dea
	join covid..covid_vaccinations as vac
	on dea.location = vac.location and dea.date =cast(vac.date as datetime)
	where dea.continent <>'0' or vac.continent <>null
	group by dea.location

--relation of max death rate, max vaccination rate, gdp of a country, population density
create view infectionRate_GDP as
select 
	location, 
	case
		when population = 0
		then null
		else (cases/population)*100 
	end as infection_rate,
	case 
		when population = 0 
		then null
		else (deaths/population)*100 
	end as mortality_rate, 
	case
		when cases = 0
		then 0
		else (deaths/cases)*100 
	end as infection_mortality_rate,
	gdp_per_capita,
	population_density
from countryInfo



