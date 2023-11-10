Select * From Portfolio_Project..CovidDeaths$
Where continent is not Null
Order by Location,date

--Select * From Portfolio_Project..CovidDeaths$
--Order by location,date

Select location,date,population,total_cases,new_cases,total_deaths
From Portfolio_Project..CovidDeaths$
order by location, date
 
-- Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as Death_percentage
From Portfolio_Project..CovidDeaths$
Where location like '%India%' and total_deaths is not null
order by location,date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location,date,total_cases,population,(total_cases/population) * 100 as Covid_percentage
From Portfolio_Project..CovidDeaths$
Where continent is not Null
order by location,date

-- Looking at countries with highest infection rates
Select location, max(total_cases) as Max_Cases,avg(population) as Population,(max(total_cases)/avg(population))*100 as Infection_Rate
From Portfolio_Project..CovidDeaths$
where population is not null and continent is not null
group by location
order by Infection_Rate DESC

-- Showing Countries with highest death count per population
Select location, max(Cast(total_deaths as int)) as Max_deaths,avg(population) as Population,(max(total_deaths)/avg(population))*100 as Death_per_Capita
From Portfolio_Project..CovidDeaths$
group by location
order by Death_per_Capita DESC

-- Let's break things by continent
-- Showing Continents with highest death count per population
Select location, max(Cast(total_deaths as int)) as Max_deaths,avg(population) as Population,(max(total_deaths)/avg(population))*100 as Death_per_Capita
From Portfolio_Project..CovidDeaths$
where continent is null
group by location
order by Max_deaths DESC

--Global Numbers
Select date, Sum(new_cases) as Total_new_cases,Sum(Cast(new_deaths as int)) as Total_new_deaths,Sum(Cast(new_deaths as float))/Sum(new_cases) *100 as New_Deaths_to_New_Cases
From Portfolio_Project..CovidDeaths$
where continent is not null
group by date
order by Total_new_cases DESC

--Looking at Total Population vs Vaccinations

Select CD.continent,CD.location,CD.date, CV.new_vaccinations,CD.population,SUM(Cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths$  as CD
Join  Portfolio_Project..CovidVaccinations$ as CV
ON CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
Order by location,date

--Using CTE

With CTE (continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
Select CD.continent,CD.location,CD.date,CD.population,CV.New_vaccinations,SUM(Cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths$  as CD
Join  Portfolio_Project..CovidVaccinations$ as CV
ON CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
--Order by location,date
)

Select * ,(Rolling_People_Vaccinated/population) * 100 as Vaccination_Percentage
From CTE

--TEMP TABLE

Drop Table PercentPopulationVaccinated
Create Table PerPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into PerPopulationVaccinated
Select CD.continent,CD.location,CD.date,CD.population,CV.New_vaccinations,SUM(Cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths$  as CD
Join  Portfolio_Project..CovidVaccinations$ as CV
ON CD.location = CV.location and CD.date = CV.date
--where CD.continent is not null
Select * ,(Rolling_People_Vaccinated/population) * 100 as Vaccination_Percentage
From PerPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercPopulationVaccinated as
Select CD.continent,CD.location,CD.date,CD.population,CV.New_vaccinations,SUM(Cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths$  as CD
Join  Portfolio_Project..CovidVaccinations$ as CV
ON CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
