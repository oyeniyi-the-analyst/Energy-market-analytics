-- now that unpivoting, chunking and streaming (loading) to mysql tables has been done in python jupyter notebooks, what enterprise grade top 0.1% content should now go into 3.1_schema_create.sql for this project.

-- 1. Staging table creation

-- -- STAGING TABLES: stg_weather_raw, stg_demand, stg_price
-- Holds raw unpivoted data exactly as received



-- Python loader inserts into this table per chunk.



-- 3. Row Count Validation
SELECT 'weather' AS table_name, COUNT(*) AS row_count FROM stg_weather_raw;
SELECT 'demand' AS table_name, COUNT(*) AS row_count FROM stg_demand;
SELECT 'price' AS table_name, COUNT(*) AS row_count FROM stg_price;
SELECT 'city_attributes' AS table_name, COUNT(*) AS row_count FROM stg_city_attributes;

-- 4. Data Quality Checks

-- weather
SELECT COUNT(*) AS null_datetimes
FROM stg_weather_raw
WHERE datetime_utc IS NULL;
-- demand
SELECT COUNT(*) AS bad_demand_rows
FROM stg_demand
WHERE Value IS NULL OR CountryCode IS NULL;
-- Price
SELECT COUNT(*) AS bad_price_rows
FROM stg_price
WHERE Price_EUR_MWhe IS NULL;
-- City Attributes
SELECT COUNT(*) AS bad_city_rows
FROM stg_city_attributes
WHERE City IS NULL OR latitude IS NULL OR longitude IS NULL;

-- 5. Deduplication Rules
DELETE t1 FROM stg_city_attributes t1
JOIN stg_city_attributes t2
  ON t1.City = t2.City
 AND t1.raw_id > t2.raw_id;

-- 6. Indexing for downstream performance
CREATE INDEX idx_weather_datetime ON stg_weather_raw(datetime_utc);
CREATE INDEX idx_demand_date ON stg_demand(DateUTC);
CREATE INDEX idx_price_datetime ON stg_price(Datetime_UTC);
CREATE INDEX idx_city_cityname ON stg_city_attributes(City);
