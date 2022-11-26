SELECT *
FROM PortfolioProject.dbo.co
 ORDER BY 3, 4


/****** Data to be used ******/
SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortfolioProject.dbo.co
  ORDER BY 1, 2

  -- Total Cases vs Total Death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
  FROM PortfolioProject.dbo.co
  WHERE location Like '%states%'
  ORDER BY 1, 2

    -- Total Cases vs population
	-- population percentage

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Percentage
  FROM PortfolioProject.dbo.co
  --WHERE location Like '%states%'
  ORDER BY 1, 2

  -- countries with highest infection rate compared with population
 SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Population_infected_Percentage
  FROM PortfolioProject.dbo.co
  --WHERE location Like '%states%'
  GROUP BY location, population
  ORDER BY Population_infected_Percentage DESC


   -- countries with highest deaths_count per population
 SELECT location, MAX(total_deaths) AS total_deaths_count
  FROM PortfolioProject.dbo.co
  --WHERE location Like '%states%'
  WHERE continent is not NULL
  GROUP BY location
  ORDER BY total_deaths_count DESC

-- continent with highest deaths_count per population
 SELECT continent , MAX(total_deaths) AS total_deaths_count
  FROM PortfolioProject.dbo.co
  --WHERE location Like '%states%'
  WHERE continent is not NULL
  GROUP BY continent 
  ORDER BY total_deaths_count DESC


--Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) /sum(new_cases)*100 AS Death_Percentage
  FROM PortfolioProject.dbo.co
 -- WHERE location Like '%states%'
  WHERE continent is not NULL
  GROUP BY date
  ORDER BY 1, 2

  --total populaton vs vaccinations

SELECT co.continent, co.location, co.date, co.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by co.location order by co.location, co.date) AS Rolling_people_vacinated
  FROM PortfolioProject.dbo.co  co
  Join PortfolioProject.dbo.Covidvac  vac
     On co.location = vac.location
	 and co.date= vac.date
	 WHERE co.continent is not NULL
	  ORDER BY 2, 3

--CTE TABLES

With PopvsVac(continent, location, date, population, new_vaccinations, Rolling_people_vacinated)
As
(
SELECT co.continent, co.location, co.date, co.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by co.location order by co.location, co.date) AS Rolling_people_vacinated
  FROM PortfolioProject.dbo.co  co
  Join PortfolioProject.dbo.Covidvac  vac
     On co.location = vac.location
	 and co.date= vac.date
	 WHERE co.continent is not NULL
)

SELECT *, (Rolling_people_vacinated/population)*100
FROM PopvsVac
ORDER BY 2, 3


--Temp Table
Drop Table if exists PercentPeopleVacinated --incase changes is to be made in the table
Create Table PercentPeopleVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Dt Date,
Population numeric,
new_vaccinations numeric, 
Rolling_people_vacinated numeric
)

insert PercentPeopleVacinated
SELECT co.continent, co.location, co.date, co.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by co.location order by co.location, co.date) AS Rolling_people_vacinated
  FROM PortfolioProject.dbo.co  co
  Join PortfolioProject.dbo.Covidvac  vac
     On co.location = vac.location
	 and co.date= vac.date
	 WHERE co.continent is not NULL

SELECT *, (Rolling_people_vacinated/population)*100
FROM PercentPeopleVacinated
ORDER BY 2, 3


-- Create View

Create View PercentPopulationVacinated 
as
  SELECT co.continent, co.location, co.date, co.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (Partition by co.location order by co.location, co.date) AS Rolling_people_vacinated
  FROM PortfolioProject.dbo.co  co
  Join PortfolioProject.dbo.Covidvac  vac
     On co.location = vac.location
	 and co.date= vac.date
	 WHERE co.continent is not NULL