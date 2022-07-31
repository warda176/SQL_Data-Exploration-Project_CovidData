--EXPLORING COVID DEATH DATA

  SELECT *
  FROM [CovidProject].[dbo].[CovidDeaths$]
  order by 3
 
  -- there are some erroronous records in location column, continent name is written inplace of location
  
  SELECT distinct(continent)
    FROM [CovidProject].[dbo].[CovidDeaths$]

  SELECT count(distinct(location))
  FROM [CovidProject].[dbo].[CovidDeaths$]
 
  SELECT distinct(location)
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where continent is not null
  order by 1

  SELECT distinct(location)
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where continent is null
  order by 1


  --looking at the data we want to work with, where there is no erronous record in location column


  SELECT location,date, total_cases, total_deaths,population
  FROM [CovidProject].[dbo].[CovidDeaths$]
    where continent is null

  order by 1,2

  --looking at total cases VS total deaths in US

  SELECT location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where location = 'United States'  and continent is not null
  order by 1,2


  --looking at total cases VS total deaths in pakistan
  --shows likelihood of dying if you intact covid in your country

  SELECT location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where location = 'Pakistan' and continent is not null



   --looking at total cases VS population in pakistan
  --shows what percent of population got covid in pakistan

  SELECT location,date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where location = 'Pakistan' and continent is not null
  order by 1 desc


    --looking at country highest infection rate vs population
    --shows what percent of population got covid at each location

 SELECT location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
  FROM [CovidProject].[dbo].[CovidDeaths$]
    where continent is not null
  group by location, population
  order by PercentPopulationInfected desc

  --shows what percent of population got covid at each location

  SELECT location,max(total_cases/population)*100 as PercentPopulationInfected
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where continent is not null
  group by location
  order by PercentPopulationInfected desc
  

--looking at covid cases and deaths GLOBALLY each day

 SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
 sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where continent is not null
  group by date
  order by 1,4

  -- deathpercentage accross the world

  SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
  FROM [CovidProject].[dbo].[CovidDeaths$]
  where continent is not null
  --group by date
  order by 1


  -- joining deaths and vaccination table

  SELECT *
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
  on dea.location = vac.location and dea.date= vac.date

  --looking at how many people got vaccinated 

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
  order by 2,3


 -- looing at rolling sum of vaccinations every day partitioned by locations

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
   over(partition by dea.location order by dea.location, dea.date ) as rollingvaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
   where dea.continent is not null

   --looking at total vaccinations in each continent

    SELECT dea.continent,  sum(cast(vac.new_vaccinations as int)) VaccinationCount
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
  where dea.continent is not null
  group by dea.continent
  order by 1

  --how many people in each country got vaccinated in terms of %
  ---using CTE for this purpose

  With PopVac as
  (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
   over(partition by dea.location order by dea.location, dea.date ) as rollingvaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
   where dea.continent is not null
  order by 2,3)

   select * ,(rollingvaccinations/population)*100 as PercentPopVaccinated
   from PopVac


  --checking maximum % of population vaccinated in each continent
  --creating temporary table for this purpose

   drop table if exists PercentPopulationVaccinated
   CREATE TABLE PercentPopulationVaccinated
  (
  continent varchar(255),
   location varchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric,
   rollingvaccinations numeric  )


  Insert into PercentPopulationVaccinated

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
   over(partition by dea.location order by dea.location, dea.date ) as rollingvaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
   where dea.continent is not null 
     order by 2,3

   select continent, max(rollingvaccinations/population)*100 as PercentPopVaccinated
   from PercentPopulationVaccinated
   group by continent



  --checking maximum % of population vaccinated in each country

   drop table if exists PercentPopulationVaccinated
   CREATE TABLE PercentPopulationVaccinated
  (
  continent varchar(255),
   location varchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric,
   rollingvaccinations numeric  )


  Insert into PercentPopulationVaccinated

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
   over(partition by dea.location order by dea.location, dea.date ) as rollingvaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
   where dea.continent is not null 
     order by 2,3

   select location
   , max(rollingvaccinations/population)*100 as PercentPopVaccinated
   from PercentPopulationVaccinated
   group by location
   order by location


   --Creating view for storing data for visualization later on

  GO
 Create view PercentPopulationVaccinatedView0 as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
   over(partition by dea.location order by dea.location, dea.date ) as rollingvaccinations
  FROM [CovidProject].[dbo].[CovidDeaths$] dea 
  join [CovidProject].[dbo].[CovidVaccinations$] vac
      on dea.location = vac.location
	  and dea.date= vac.date
   where dea.continent is not null 
   
   GO
   SELECT *
   from PercentPopulationVaccinatedView0