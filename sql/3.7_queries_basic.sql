-- 3.7 BASIC ANALYTICS QUERIES (SCHEMA‑ACCURATE VERSION)
   -- Using: tmp_cleaned_demand, tmp_cleaned_price, stg_city_attributes

--    1. Total Demand by Country (from tmp_cleaned_demand)
SELECT 
    country_code,
    SUM(value) AS total_demand_mwh
FROM tmp_cleaned_demand
GROUP BY country_code
ORDER BY total_demand_mwh DESC;


-- 2. Average Price by Country (from tmp_cleaned_price)
SELECT
    ISO3_Code AS country_code,
    ROUND(AVG(Price_EUR_MWhe), 2) AS avg_price_eur_mwh
FROM tmp_cleaned_price
GROUP BY ISO3_Code
ORDER BY avg_price_eur_mwh DESC;


--   3. Monthly Demand Trend
   SELECT
    YEAR(datetime_utc) AS year,
    MONTH(datetime_utc) AS month,
    SUM(value) AS monthly_demand_mwh
FROM tmp_cleaned_demand
GROUP BY YEAR(datetime_utc), MONTH(datetime_utc)
ORDER BY year, month;


--   4. Monthly Price Trend
   
SELECT
    YEAR(datetime_utc) AS year,
    MONTH(datetime_utc) AS month,
    ROUND(AVG(Price_EUR_MWhe), 2) AS monthly_avg_price
FROM tmp_cleaned_price
GROUP BY YEAR(datetime_utc), MONTH(datetime_utc)
ORDER BY year, month;


--    5. Demand vs Price Correlation Inputs
-- (Join on datetime_utc + country_code)

SELECT
    d.value AS demand_mwh,
    p.Price_EUR_MWhe AS price_eur_mwh
FROM tmp_cleaned_demand d
JOIN tmp_cleaned_price p
    ON d.datetime_utc = p.datetime_utc
   AND d.country_code = p.ISO3_Code
WHERE d.value IS NOT NULL
  AND p.Price_EUR_MWhe IS NOT NULL;

--    7. Highest Price Day per Country

SELECT
    YEAR(datetime_utc) AS year,
    SUM(value) AS yearly_demand_mwh
FROM tmp_cleaned_demand
GROUP BY YEAR(datetime_utc)
ORDER BY year;


--    9. Yearly Price Summary
   SELECT
    YEAR(datetime_utc) AS year,
    ROUND(AVG(Price_EUR_MWhe), 2) AS yearly_avg_price
FROM tmp_cleaned_price
GROUP BY YEAR(datetime_utc)
ORDER BY year;


--   10. Country Ranking (Demand + Price)
   
SELECT
    d.country_code,
    SUM(d.value) AS total_demand_mwh,
    ROUND(AVG(p.Price_EUR_MWhe), 2) AS avg_price_eur_mwh
FROM tmp_cleaned_demand d
LEFT JOIN tmp_cleaned_price p
    ON d.country_code = p.ISO3_Code
GROUP BY d.country_code
ORDER BY total_demand_mwh DESC;
