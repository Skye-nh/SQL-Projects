-- This is a data exploration that will look at the impact of COVID-19 (1/1/2020 - 4/30/2021) between each country and key indicators for each country.

--The following queries will look at prevalence and mortality of COVID-19 by country.

--Selecting data that will be used for analysis
Select continent, location, date, new_cases, total_cases, new_deaths, total_deaths, population
From covid_deaths
Order By location, date;
--Note: When continent is null, location data provided is etiher continent or 'Global". To look at data by country, data containing null values under continent will be removed.

--Total people infected per country
Select location, SUM(new_cases) as total_cases_per_country
From covid_deaths
Where continent is NOT NULL
Group by location
Order by total_cases_per_country desc

--Total people infected per country per 100k (Infection Rate)
Select location, ROUND((MAX(total_cases)/population)*100000,2) as total_cases_per_100kpop
From covid_deaths
Where continent is NOT NULL
Group by location, population
Order by total_cases_per_100kpop desc

--Note: 'new_%' and 'total_%' records use rolling totals, so SUM('new_%') and MAX('total_%') can be used interchangably.

--Case Fatality Ratio by country per 100k
Select location, ROUND((SUM(CONVERT(int,new_deaths))/SUM(new_cases))*100,2) as case_fatality_ratio
From covid_deaths
Where continent is NOT NULL
Group by location
Order by case_fatality_ratio desc

--Death Rate by country per 100k
Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate
From covid_deaths
Where continent is NOT NULL
Group by location, population
Order by death_rate desc

--The following queries will look at death rate by country compared to key indicators of their development. 
--Each indicator has two queries correspinding to countries that fall within the developed or underdeveloped categories

--Life Expectancy
-- Average global life expectancy = 72.27

--Death Rate (per 100k) vs Life Expectancy (above global average)
With life_exp_threshold AS 
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, life_expectancy,
Case
	WHEN life_expectancy >= 72.27 THEN 'Above Global Average'
	WHEN life_expectancy < 72.27 THEN 'Below Global Aberage'
	ELSE 'NULL'
END as life_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, life_expectancy)
--
Select location, death_rate, life_expectancy
From life_exp_threshold
Where life_threshold = 'Above Global Average'
Order by death_rate desc


--Death Rate (per 100k) vs Life Expectancy (below global average)
With life_exp_threshold AS 
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, life_expectancy,
Case
	WHEN life_expectancy >= 72.27 THEN 'Above Global Average'
	WHEN life_expectancy < 72.27 THEN 'Below Global Average'
	ELSE 'NULL'
END as life_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, life_expectancy)
--
Select location, death_rate, life_expectancy
From life_exp_threshold
Where life_threshold = 'Below Global Average'
Order by death_rate desc

--Human Development Index (HDI)
--HDI cutoff for developed country = 0.8

--Death Rate (per 100k) vs HDI (above developed threshold)
With HDI AS
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, human_development_index,
Case
	WHEN human_development_index >= 0.8 THEN 'Above Developed Threshold'
	WHEN human_development_index < 0.8 THEN 'Below Developed Threshold'
	ELSE 'NULL'
END as hdi_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, human_development_index)
--
Select location, death_rate, human_development_index
From HDI
Where hdi_threshold = 'Above Developed Threshold'
Order by death_rate desc

--Death Rate (per 100k) vs HDI (below developed threshold)
With HDI AS
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, human_development_index,
Case
	WHEN human_development_index >= 0.8 THEN 'Above Developed Threshold'
	WHEN human_development_index < 0.8 THEN 'Below Developed Threshold'
	ELSE 'NULL'
END as hdi_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, human_development_index)
--
Select location, death_rate, human_development_index
From HDI
Where hdi_threshold = 'Below Developed Threshold'
Order by death_rate desc

--GDP Per Capita
--GDP Per Capita cutoff for developed country = $20,000*

--Death Rate (per 100k) vs GDP Per Capita (above developed threshold)
With GDP AS
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, gdp_per_capita,
Case
	WHEN gdp_per_capita >= 20000 THEN 'Above Developed Threshold'
	WHEN gdp_per_capita < 2000 THEN 'Below Developed Threshold'
	ELSE 'NULL'
END as gdp_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, gdp_per_capita)
--
Select location, death_rate, gdp_per_capita
From GDP
Where gdp_threshold = 'Above Developed Threshold'
Order by death_rate desc


--Death Rate (per 100k) vs GDP Per Capita (below developed threshold)
With GDP AS
(Select location, ROUND((MAX(CONVERT(int, total_deaths))/population)*100000,2) as death_rate, gdp_per_capita,
Case
	WHEN gdp_per_capita >= 20000 THEN 'Above Developed Threshold'
	WHEN gdp_per_capita < 2000 THEN 'Below Developed Threshold'
	ELSE 'NULL'
END as gdp_threshold
From covid_deaths
Where continent is NOT NULL
Group by location, population, gdp_per_capita)
--
Select location, death_rate, gdp_per_capita
From GDP
Where gdp_threshold = 'Below Developed Threshold'
Order by death_rate desc

--* the cutoff for GDP Per Capita has been defined within of wide range ($12,000-$30,000). Results will vary based on defined cutoff for GDP Per Capita.


--The final queries use a second data set to compare death rate to response methods (testing, vaccinations) to COVID-19.

--Death Rate and testing by country over time
Select dea.date, dea.location, dea.population, ROUND((MAX(CONVERT(int, dea.total_deaths))/dea.population)*100000,2) as death_rate, ROUND((MAX(CONVERT(int, vac.total_tests))/dea.population)*100000,2) as test_rate
From covid19..covid_deaths AS dea
JOIN covid19..covid_vac AS vac
ON dea.location = vac.location
AND dea.date = vac.date
Group by dea.date, dea.location, dea.population
Order by location, date

--Death Rate and vaccinations by country over time
Select dea.date, dea.location, dea.population, ROUND((MAX(CONVERT(int, dea.total_deaths))/dea.population)*100000,2) as death_rate, ROUND((MAX(CONVERT(int, vac.total_vaccinations))/dea.population)*100000,2) as vaccination_rate
From covid19..covid_deaths AS dea
JOIN covid19..covid_vac AS vac
ON dea.location = vac.location
AND dea.date = vac.date
Group by dea.date, dea.location, dea.population
Order by location, date

--Next Step: Prepare queries for visualization in tableau to copmare impacts of covid and key indicators for each country.