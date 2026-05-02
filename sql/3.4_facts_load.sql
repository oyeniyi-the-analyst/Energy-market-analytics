USE electricity_capstone;

SET sql_safe_updates = 0;
SET foreign_key_checks = 0;

START TRANSACTION;

-- METADATA
SET @batch_id    = UNIX_TIMESTAMP();
SET @pipeline_id = 'etl_v1';
SET @run_ts      = NOW();

ALTER TABLE fact_demand
    ADD UNIQUE KEY uq_fact_demand (time_id, country_id);

ALTER TABLE fact_price
    ADD UNIQUE KEY uq_fact_price (time_id, country_id);


-- FACT_DEMAND
INSERT INTO fact_demand (
    time_id,
    country_id,
    cov_ratio,
    value,
    value_scaled,
    batch_id,
    pipeline_id,
    load_ts
)
SELECT
    dt.time_id,
    dc.country_id,
    td.cov_ratio,
    td.value,
    td.value_scaled,
    @batch_id,
    @pipeline_id,
    @run_ts
FROM tmp_cleaned_demand td
JOIN dim_time dt
    ON dt.datetime_utc = td.datetime_utc
JOIN dim_country dc
    ON dc.country_name COLLATE utf8mb4_unicode_ci =
       td.country_code COLLATE utf8mb4_unicode_ci
LEFT JOIN fact_demand fd
    ON fd.time_id = dt.time_id
   AND fd.country_id = dc.country_id
WHERE fd.demand_id IS NULL;

-- FACT_PRICE
INSERT INTO fact_price (
    time_id,
    country_id,
    price_eur_mwhe,
    batch_id,
    pipeline_id,
    load_ts
)
SELECT
    dt.time_id,
    dc.country_id,
    tp.price_eur_mwhe,
    @batch_id,
    @pipeline_id,
    @run_ts
FROM tmp_cleaned_price tp
JOIN dim_time dt
    ON dt.datetime_utc = tp.datetime_utc
JOIN dim_country dc
    ON dc.country_name COLLATE utf8mb4_unicode_ci =
       tp.country_name COLLATE utf8mb4_unicode_ci
LEFT JOIN fact_price fp
    ON fp.time_id = dt.time_id
   AND fp.country_id = dc.country_id
WHERE fp.price_id IS NULL;

COMMIT;

SET foreign_key_checks = 1;

SELECT * FROM fact_demand LIMIT 10;
SELECT * FROM fact_demand;
SELECT * FROM fact_price LIMIT 10;
SELECT count(*) FROM fact_price;

-- COMBINED DIAGNOSTIC REPORT FOR fact_demand

-- 1. Total rows vs inserted vs skipped
SELECT
    'row_summary' AS section,
    (SELECT COUNT(*) FROM tmp_cleaned_demand) AS staging_rows,
    (SELECT COUNT(*) FROM fact_demand) AS fact_rows,
    (SELECT COUNT(*) FROM tmp_cleaned_demand) -
    (SELECT COUNT(*) FROM fact_demand) AS skipped_rows;

-- 2. Invalid ISO2 codes
SELECT
    'invalid_iso2' AS section,
    d.country_code AS invalid_iso2,
    COUNT(*) AS row_count
FROM tmp_cleaned_demand d
LEFT JOIN dim_country c
    ON UPPER(d.country_code) = UPPER(c.country_code)
WHERE c.country_id IS NULL
GROUP BY d.country_code
ORDER BY row_count DESC;

-- 3. Timestamps not found in dim_time
SELECT
    'invalid_timestamp' AS section,
    d.datetime_utc AS invalid_timestamp,
    COUNT(*) AS row_count
FROM tmp_cleaned_demand d
LEFT JOIN dim_time t
    ON d.datetime_utc = t.datetime_utc
WHERE t.time_id IS NULL
GROUP BY d.datetime_utc
ORDER BY row_count DESC;

-- 4. Duplicate (time_id, country_id) pairs
SELECT
    'duplicates' AS section,
    t.time_id,
    c.country_id,
    COUNT(*) AS occurrences
FROM tmp_cleaned_demand d
JOIN dim_time t
    ON d.datetime_utc = t.datetime_utc
JOIN dim_country c
    ON UPPER(d.country_code) = UPPER(c.country_code)
GROUP BY t.time_id, c.country_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

