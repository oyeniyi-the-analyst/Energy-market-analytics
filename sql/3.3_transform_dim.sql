USE electricity_capstone;

SET sql_safe_updates = 0;
SET foreign_key_checks = 0;

START TRANSACTION;

-- METADATA
-- Uses session variables:
SET @batch_id    = UNIX_TIMESTAMP();
SET @pipeline_id = 'etl_v1';
SET @run_ts      = NOW();

-- DIM_COUNTRY
INSERT INTO dim_country (
    country_code,
    country_name,
    iso3,
    source_hash,
    first_seen,
    last_seen,
    batch_id,
    pipeline_id
)
SELECT
    unified.country_code,
    unified.country_name,
    unified.iso3,
    MD5(CONCAT_WS('|', unified.country_code, unified.country_name, unified.iso3)),
    @run_ts,
    @run_ts,
    @batch_id,
    @pipeline_id
FROM (

-- Source 1: tmp_cleaned_price (best source: name + iso3)
    SELECT DISTINCT
        NULL AS country_code,
        country_name,
        iso3
    FROM tmp_cleaned_price
    WHERE country_name IS NOT NULL
      AND iso3 IS NOT NULL
    UNION
    
-- Source 2: tmp_cleaned_demand (ISO2 only)
    SELECT DISTINCT
        country_code,
        NULL AS country_name,
        NULL AS iso3
    FROM tmp_cleaned_demand
    WHERE country_code IS NOT NULL
    UNION

-- Source 3: tmp_cleaned_city_attributes (country_name only)
    SELECT DISTINCT
        NULL AS country_code,
        country AS country_name,
        NULL AS iso3
    FROM tmp_cleaned_city_attributes
    WHERE country IS NOT NULL

) AS unified
LEFT JOIN dim_country dc
    ON dc.country_name COLLATE utf8mb4_unicode_ci =
       unified.country_name COLLATE utf8mb4_unicode_ci
WHERE unified.country_name IS NOT NULL
  AND dc.country_id IS NULL;
  
INSERT IGNORE INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM country_code_name_map
WHERE country_name IS NOT NULL;

UPDATE dim_country SET country_code='AT' WHERE country_name='Austria';
UPDATE dim_country SET country_code='BE' WHERE country_name='Belgium';
UPDATE dim_country SET country_code='BG' WHERE country_name='Bulgaria';
UPDATE dim_country SET country_code='CA' WHERE country_name='Canada';
UPDATE dim_country SET country_code='HR' WHERE country_name='Croatia';
UPDATE dim_country SET country_code='CZ' WHERE country_name='Czechia';
UPDATE dim_country SET country_code='DK' WHERE country_name='Denmark';
UPDATE dim_country SET country_code='EE' WHERE country_name='Estonia';
UPDATE dim_country SET country_code='FI' WHERE country_name='Finland';
UPDATE dim_country SET country_code='FR' WHERE country_name='France';
UPDATE dim_country SET country_code='DE' WHERE country_name='Germany';
UPDATE dim_country SET country_code='GR' WHERE country_name='Greece';
UPDATE dim_country SET country_code='HU' WHERE country_name='Hungary';
UPDATE dim_country SET country_code='IE' WHERE country_name='Ireland';
UPDATE dim_country SET country_code='IL' WHERE country_name='Israel';
UPDATE dim_country SET country_code='IT' WHERE country_name='Italy';
UPDATE dim_country SET country_code='LV' WHERE country_name='Latvia';
UPDATE dim_country SET country_code='LT' WHERE country_name='Lithuania';
UPDATE dim_country SET country_code='LU' WHERE country_name='Luxembourg';
UPDATE dim_country SET country_code='NL' WHERE country_name='Netherlands';
UPDATE dim_country SET country_code='MK' WHERE country_name='North Macedonia';
UPDATE dim_country SET country_code='NO' WHERE country_name='Norway';
UPDATE dim_country SET country_code='PL' WHERE country_name='Poland';
UPDATE dim_country SET country_code='PT' WHERE country_name='Portugal';
UPDATE dim_country SET country_code='RO' WHERE country_name='Romania';
UPDATE dim_country SET country_code='RS' WHERE country_name='Serbia';
UPDATE dim_country SET country_code='SK' WHERE country_name='Slovakia';
UPDATE dim_country SET country_code='SI' WHERE country_name='Slovenia';
UPDATE dim_country SET country_code='ES' WHERE country_name='Spain';
UPDATE dim_country SET country_code='SE' WHERE country_name='Sweden';
UPDATE dim_country SET country_code='CH' WHERE country_name='Switzerland';
UPDATE dim_country SET country_code='US' WHERE country_name='United States';

SELECT country_name, country_code FROM dim_country ORDER BY country_name;

-- DIM CITY
SET @batch_id    = UNIX_TIMESTAMP();
SET @pipeline_id = 'etl_v1';
SET @run_ts      = NOW();

INSERT INTO dim_city (
    city_name,
    country_id,
    latitude,
    longitude,
    source_hash,
    first_seen,
    last_seen,
    batch_id,
    pipeline_id
)
SELECT
    cca.city,
    dc.country_id,
    cca.latitude,
    cca.longitude,
    MD5(CONCAT_WS('|', cca.city, cca.country, cca.latitude, cca.longitude)),
    @run_ts,
    @run_ts,
    @batch_id,
    @pipeline_id
FROM tmp_cleaned_city_attributes AS cca
JOIN dim_country AS dc
    ON dc.country_name COLLATE utf8mb4_unicode_ci =
       cca.country COLLATE utf8mb4_unicode_ci
LEFT JOIN dim_city AS c
    ON c.city_name COLLATE utf8mb4_unicode_ci =
       cca.city COLLATE utf8mb4_unicode_ci
   AND c.country_id = dc.country_id
WHERE c.city_id IS NULL;


-- DIM_TIME
SET @batch_id    = UNIX_TIMESTAMP();
SET @pipeline_id = 'etl_v1';
SET @run_ts      = NOW();

INSERT INTO dim_time (
    datetime_utc,
    date,
    hour,
    day_of_week,
    month,
    year,
    is_weekend,
    source_hash,
    first_seen,
    last_seen,
    batch_id,
    pipeline_id
)
SELECT
    t.datetime_utc,
    DATE(t.datetime_utc),
    HOUR(t.datetime_utc),
    DAYOFWEEK(t.datetime_utc),
    MONTH(t.datetime_utc),
    YEAR(t.datetime_utc),
    CASE WHEN DAYOFWEEK(t.datetime_utc) IN (1,7) THEN 1 ELSE 0 END,
    MD5(t.datetime_utc),
    @run_ts,
    @run_ts,
    @batch_id,
    @pipeline_id
FROM (
-- Source 1: tmp_cleaned_price
    SELECT DISTINCT datetime_utc
    FROM tmp_cleaned_price
    WHERE datetime_utc IS NOT NULL
    UNION

-- Source 2: tmp_cleaned_demand
    SELECT DISTINCT datetime_utc
    FROM tmp_cleaned_demand
    WHERE datetime_utc IS NOT NULL
) AS t
LEFT JOIN dim_time dt
    ON dt.datetime_utc = t.datetime_utc
WHERE dt.time_id IS NULL;



COMMIT;

SET foreign_key_checks = 1;


-- VALIDATION CHECKS
SELECT 'dim_country' AS table_name, COUNT(*) AS row_count FROM dim_country;
SELECT * FROM dim_country;
SELECT 'dim_city'    AS table_name, COUNT(*) AS row_count FROM dim_city;
SELECT * FROM dim_city;
SELECT 'dim_time'    AS table_name, COUNT(*) AS row_count FROM dim_time;
SELECT * FROM dim_time;

SELECT 'tmp_cleaned_demand' AS table_name, COUNT(*) AS row_count FROM tmp_cleaned_demand;
SELECT 'tmp_cleaned_price'  AS table_name, COUNT(*) AS row_count FROM tmp_cleaned_price;
SELECT 'tmp_cleaned_city_attributes' AS table_name, COUNT(*) AS row_count FROM tmp_cleaned_city_attributes;
