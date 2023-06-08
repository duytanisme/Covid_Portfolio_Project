SELECT * 
  FROM Project_for_Portfolio..CovidDeaths
  WHERE location = 'Canada'
  ORDER BY 3, 4

--select * from CovidVaccinations
--order by 3,4

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
  
  FROM Project_for_Portfolio..CovidDeaths
  ORDER BY 1,2

-- looking at total_cases and total_deaths
-- cast arguments as float due to inital data type of them (nvarchar -> float)

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS death_percentage
  
  FROM Project_for_Portfolio..CovidDeaths
  WHERE location like	'Vietnam'
  ORDER BY 1,2

-- total_cases and population

SELECT 
	location, 
	date, 
	population, 
	total_cases, total_deaths, 
	CAST(total_cases AS decimal(20,10))/CAST(population AS decimal(20,10))*100 AS infection_percentage
  
  FROM Project_for_Portfolio..CovidDeaths
--WHERE location like	'Vietnam'
  ORDER BY 1,2

-- top countries with highest infection rate

SELECT 
	location,
	population,
	max(total_cases) AS highest_infection_count,
	MAX(CAST(total_cases AS decimal(20,10))/CAST(population AS decimal(20,10)))*100 AS infection_percentage

  FROM Project_for_Portfolio..CovidDeaths
  
  GROUP BY location, population
  
  ORDER BY infection_percentage DESC


-- top countries with highest death count

SELECT
	continent,
	location,
	max(cast(total_deaths AS int)) AS total_deaths_count

  FROM Project_for_Portfolio..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent, location
  ORDER BY total_deaths_count DESC


-- top continent with highest death count

SELECT cont.continent, sum(cont.highest_deaths_count) AS cont_sum_death
  FROM(
	SELECT
		continent, 
		location,
		max(cast(total_deaths AS int)) AS highest_deaths_count
	  FROM Project_for_Portfolio..CovidDeaths
	  WHERE continent IS NOT NULL
	  GROUP BY continent, location) AS cont
  GROUP BY cont.continent
  ORDER BY cont_sum_death DESC



-- continent with highest population

SELECT pop.continent, sum(pop.country_population) AS cont_sum_population
  FROM(
	SELECT
		continent,
		location, 
		max(population) AS country_population
	  FROM Project_for_Portfolio..CovidDeaths
	  WHERE continent IS NOT NULL
	  GROUP BY continent, location) AS pop
  GROUP BY pop.continent
  ORDER BY cont_sum_population DESC




-- continent with highest death count per population

SELECT 
	continent_death.continent, 
	continent_death.cont_sum_death, 
	continent_population.cont_sum_population,
	continent_death.cont_sum_death/continent_population.cont_sum_population*100 AS death_rate
  FROM(
		SELECT 
			pop.continent, 
			sum(pop.country_population) AS cont_sum_population
	      FROM(
				SELECT
					continent,
					location, 
					max(population) AS country_population
				  FROM Project_for_Portfolio..CovidDeaths
				  WHERE continent IS NOT NULL
				  GROUP BY continent, location) AS pop
		  GROUP BY pop.continent) AS continent_population
  JOIN(
		SELECT 
			cont.continent, 
			sum(cont.highest_deaths_count) AS cont_sum_death
		  FROM(
				SELECT
					continent, 
					location,
					max(cast(total_deaths AS int)) AS highest_deaths_count
				  FROM Project_for_Portfolio..CovidDeaths
				  WHERE continent IS NOT NULL
				  GROUP BY continent, location) AS cont
		  GROUP BY cont.continent) AS continent_death
  ON continent_death.continent = continent_population.continent
  ORDER BY death_rate DESC
	
