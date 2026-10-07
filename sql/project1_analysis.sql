-- Project 1: Global Economic & Financial Indicators
-- SQLite-compatible SQL
-- Dataset: data/global_economic_indicators.csv
--
-- If using PostgreSQL/MySQL, adapt the CSV import command as needed.

DROP TABLE IF EXISTS economic_indicators;

CREATE TABLE economic_indicators (
    country TEXT NOT NULL,
    iso3 TEXT NOT NULL,
    year INTEGER NOT NULL,
    gdp_current_usd_bn REAL,
    gdp_per_capita_usd REAL,
    inflation_pct REAL,
    unemployment_pct REAL,
    trade_pct_gdp REAL,
    real_interest_rate_pct REAL,
    PRIMARY KEY (iso3, year)
);

-- SQLite CLI import:
-- .mode csv
-- .headers on
-- .import data/global_economic_indicators.csv economic_indicators

CREATE INDEX idx_economic_country_year
ON economic_indicators (country, year);

-- 1. Latest economic snapshot
SELECT *
FROM economic_indicators
WHERE year = (SELECT MAX(year) FROM economic_indicators)
ORDER BY gdp_current_usd_bn DESC;

-- 2. GDP CAGR from first to last year
WITH bounds AS (
    SELECT
        iso3,
        country,
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM economic_indicators
    GROUP BY iso3, country
)
SELECT
    b.country,
    b.first_year,
    b.last_year,
    ROUND(
        (POWER(e2.gdp_current_usd_bn / e1.gdp_current_usd_bn,
               1.0 / (b.last_year - b.first_year)) - 1) * 100,
        2
    ) AS gdp_cagr_pct
FROM bounds b
JOIN economic_indicators e1
  ON e1.iso3 = b.iso3 AND e1.year = b.first_year
JOIN economic_indicators e2
  ON e2.iso3 = b.iso3 AND e2.year = b.last_year
ORDER BY gdp_cagr_pct DESC;

-- 3. Average inflation and unemployment by country
SELECT
    country,
    ROUND(AVG(inflation_pct), 2) AS avg_inflation_pct,
    ROUND(AVG(unemployment_pct), 2) AS avg_unemployment_pct
FROM economic_indicators
GROUP BY country
ORDER BY avg_inflation_pct DESC;

-- 4. Inflation spike in 2022
SELECT
    country,
    inflation_pct,
    RANK() OVER (ORDER BY inflation_pct DESC) AS inflation_rank
FROM economic_indicators
WHERE year = 2022
ORDER BY inflation_rank;

-- 5. Year-over-year GDP growth
WITH lagged AS (
    SELECT
        country,
        year,
        gdp_current_usd_bn,
        LAG(gdp_current_usd_bn) OVER (
            PARTITION BY country ORDER BY year
        ) AS prior_gdp
    FROM economic_indicators
)
SELECT
    country,
    year,
    ROUND((gdp_current_usd_bn / prior_gdp - 1) * 100, 2) AS yoy_gdp_growth_pct
FROM lagged
WHERE prior_gdp IS NOT NULL
ORDER BY country, year;

-- 6. Trade openness versus GDP per capita
SELECT
    country,
    ROUND(AVG(trade_pct_gdp), 2) AS avg_trade_pct_gdp,
    ROUND(AVG(gdp_per_capita_usd), 0) AS avg_gdp_per_capita_usd
FROM economic_indicators
GROUP BY country
ORDER BY avg_trade_pct_gdp DESC;

-- 7. Countries with below-4% unemployment in 2024
SELECT country, unemployment_pct
FROM economic_indicators
WHERE year = 2024
  AND unemployment_pct < 4
ORDER BY unemployment_pct;

-- 8. Recession-style GDP contraction check
WITH lagged AS (
    SELECT
        country,
        year,
        gdp_current_usd_bn,
        LAG(gdp_current_usd_bn) OVER (
            PARTITION BY country ORDER BY year
        ) AS prior_gdp
    FROM economic_indicators
)
SELECT
    country,
    year,
    ROUND((gdp_current_usd_bn / prior_gdp - 1) * 100, 2) AS yoy_growth_pct
FROM lagged
WHERE prior_gdp IS NOT NULL
  AND (gdp_current_usd_bn / prior_gdp - 1) < 0
ORDER BY year, yoy_growth_pct;
