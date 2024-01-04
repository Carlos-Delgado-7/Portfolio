-- Show data from the table CovidDeaths$
CREATE VIEW View_CovidDeathsData AS
    SELECT * FROM dbo.CovidDeaths$;


-- Show Death percentage by Country
CREATE VIEW View_DeathPercentageByCountry AS
    WITH RankedCovidData AS (
        SELECT
            location,
            total_cases,
            total_deaths,
            (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage,
            ROW_NUMBER() OVER (PARTITION BY location ORDER BY [date] DESC) AS RowNum
        FROM
            dbo.CovidDeaths$
        WHERE
            total_cases IS NOT NULL AND total_deaths IS NOT NULL AND continent IS NOT NULL
    )
    SELECT
        location,
        total_cases,
        total_deaths,
        DeathPercentage
    FROM
        RankedCovidData
    WHERE
        RowNum = 1;

-- Show Percentage of the total population that got Covid-19 by Country
CREATE VIEW View_PercentageGotCovidByCountry AS
    SELECT
        MAX(location) AS Location,
        MAX([date]) AS 'Date',
        MAX(population) AS Population,
        MAX(total_cases) AS TotalCases,
        MAX(PercentagegotCovid) AS PercentagegotCovid
    FROM
        (
            SELECT
                location,
                [date],
                population,
                total_cases,
                (total_cases / population) * 100 AS PercentagegotCovid
            FROM
                CovidDeaths$
            WHERE continent IS NOT NULL
        ) AS Sub1
    GROUP BY
        Sub1.location;

-- Showing countries with the Highest Death Count per population
CREATE VIEW View_HighestDeathCountByPopulation AS
    SELECT
        location,
        MAX(total_deaths) AS TotalDeathsCount
    FROM CovidDeaths$
    WHERE continent IS NOT NULL
    GROUP BY location;

-- Showing Continents with the Highest Death Count per population and total deaths in the World
CREATE VIEW View_HighestDeathCountByPopulationAndWorld AS
    SELECT
        location,
        MAX(total_deaths) AS TotalDeathsCount
    FROM CovidDeaths$ 
    WHERE continent IS NULL AND location NOT LIKE '%incom%'
    GROUP BY location;

-- Showing continent with the highest death count per population
CREATE VIEW View_HighestDeathCountByPopulationContinent AS
    SELECT
        location,
        MaxPopulation,
        MaxDeaths,
        (MaxDeaths / MaxPopulation) * 100 AS PercentageDeaths
    FROM
        (
            SELECT
                location,
                MAX(population) AS MaxPopulation,
                MAX(total_deaths) AS MaxDeaths
            FROM
                CovidDeaths$
            WHERE
                continent IS NULL
                AND location NOT LIKE '%incom%'
                AND location NOT LIKE '%World%'
            GROUP BY
                location
        ) Sub1;

-- Showing Percentage of People vaccinated by Country

CREATE VIEW View_PercentagePeopleVaccinatedByCountry AS
    SELECT 
        Sub.location,
        Sub.TotalPopulation,
        Sub.PeopleVaccinated,
        (Sub.PeopleVaccinated / Sub.TotalPopulation) * 100 as PercentagePeopleVaccinated
    FROM (
        SELECT
            dea.location,
            MAX(dea.population) as TotalPopulation,
            MAX(CAST(vac.people_vaccinated AS FLOAT)) as PeopleVaccinated
        FROM
            dbo.CovidDeaths$ dea
        JOIN
            CovidVaccinations$ vac ON dea.[date] = vac.[date]
                                   AND dea.continent = vac.continent
                                   AND dea.iso_code = vac.iso_code
                                   AND dea.location = vac.location
        -- WHERE dea.location ='Colombia'
        GROUP BY
            dea.location
    ) Sub;

-- Select from each view

SELECT * FROM View_DeathPercentageByCountry order by DeathPercentage DESC;
SELECT * FROM View_PercentageGotCovidByCountry;
SELECT * FROM View_HighestDeathCountByPopulation;
SELECT * FROM View_HighestDeathCountByPopulationAndWorld;
SELECT * FROM View_HighestDeathCountByPopulationContinent;
SELECT * FROM View_PercentagePeopleVaccinatedByCountry;
