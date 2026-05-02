-- 1. ROW COUNT RECONCILIATION
SELECT 'demand_row_counts' AS test,
       (SELECT COUNT(*) FROM tmp_cleaned_demand) AS staging_rows,
       (SELECT COUNT(*) FROM fact_demand) AS fact_rows,
       (SELECT COUNT(*) FROM tmp_cleaned_demand) -
       (SELECT COUNT(*) FROM fact_demand) AS skipped_rows;

SELECT 'price_row_counts' AS test,
       (SELECT COUNT(*) FROM tmp_cleaned_price) AS staging_rows,
       (SELECT COUNT(*) FROM fact_price) AS fact_rows,
       (SELECT COUNT(*) FROM tmp_cleaned_price) -
       (SELECT COUNT(*) FROM fact_price) AS skipped_rows;

-- 2. FOREIGN KEY INTEGRITY

SELECT 'fact_demand_missing_time' AS test, COUNT(*)
FROM fact_demand fd
LEFT JOIN dim_time t ON fd.time_id = t.time_id
WHERE t.time_id IS NULL;

SELECT 'fact_demand_missing_country' AS test, COUNT(*)
FROM fact_demand fd
LEFT JOIN dim_country c ON fd.country_id = c.country_id
WHERE c.country_id IS NULL;

SELECT 'fact_price_missing_time' AS test, COUNT(*)
FROM fact_price fp
LEFT JOIN dim_time t ON fp.time_id = t.time_id
WHERE t.time_id IS NULL;

SELECT 'fact_price_missing_country' AS test, COUNT(*)
FROM fact_price fp
LEFT JOIN dim_country c ON fp.country_id = c.country_id
WHERE c.country_id IS NULL;

-- 3. NULL & RANGE CHECKS
SELECT 'null_values_fact_demand' AS test, COUNT(*)
FROM fact_demand
WHERE cov_ratio IS NULL OR value IS NULL OR value_scaled IS NULL;

SELECT 'null_values_fact_price' AS test, COUNT(*)
FROM fact_price
WHERE price_eur_mwhe IS NULL;

SELECT 'negative_demand_values' AS test, COUNT(*)
FROM fact_demand
WHERE value < 0;

SELECT 'negative_price_values' AS test, COUNT(*)
FROM fact_price
WHERE price_eur_mwhe < 0;

-- 4. DUPLICATE KEY CHECKS

SELECT 'fact_demand_duplicates' AS test,
       time_id, country_id, COUNT(*) AS occurrences
FROM fact_demand
GROUP BY time_id, country_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT 'fact_price_duplicates' AS test,
       time_id, country_id, COUNT(*) AS occurrences
FROM fact_price
GROUP BY time_id, country_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 5. TIME COVERAGE VALIDATION

SELECT 'missing_hours_in_dim_time' AS test,
       MIN(datetime_utc), MAX(datetime_utc),
       COUNT(*) AS total_hours,
       TIMESTAMPDIFF(HOUR, MIN(datetime_utc), MAX(datetime_utc)) + 1 AS expected_hours,
       (TIMESTAMPDIFF(HOUR, MIN(datetime_utc), MAX(datetime_utc)) + 1) - COUNT(*) AS missing_hours
FROM dim_time;

SELECT 'missing_hours_in_fact_demand' AS test,
       COUNT(*) AS fact_rows,
       (SELECT COUNT(*) FROM dim_time) AS dim_time_rows,
       (SELECT COUNT(*) FROM dim_time) - COUNT(*) AS missing_hours
FROM fact_demand;

-- 6. COUNTRY COVERAGE VALIDATION

SELECT 'countries_missing_in_fact_demand' AS test,
       c.country_name
FROM dim_country c
LEFT JOIN fact_demand fd ON fd.country_id = c.country_id
WHERE fd.country_id IS NULL;

SELECT 'countries_missing_in_fact_price' AS test,
       c.country_name
FROM dim_country c
LEFT JOIN fact_price fp ON fp.country_id = c.country_id
WHERE fp.country_id IS NULL;





