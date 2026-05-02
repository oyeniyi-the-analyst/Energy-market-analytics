# ⚡ Energy Market Analytics (ETL Pipeline)

End-to-end **enterprise-style data engineering pipeline** for large-scale energy market data using **Python (Jupyter Notebooks) + MySQL**.

---

## 🚀 Overview

This project demonstrates the design and optimisation of a **scalable ETL pipeline** capable of processing **multi-million row datasets** efficiently using chunking, streaming, and data warehousing techniques.

> ⚠️ Note: This project builds on existing ETL patterns and scripts, which were **adapted, extended, and optimised** for large-scale energy data processing, performance, and reliability.

---

## 🧠 Architecture

```
Raw CSVs
   ↓
Chunking (Notebook)
   ↓
Staging Tables (MySQL)
   ↓
Cleaned Layer (tmp tables)
   ↓
Fact Tables (Star Schema)
   ↓
Diagnostics & Audit Reports
```

---

## 🛠️ Tech Stack

* Python (pandas, csv, pymysql, mysql.connector)
* Jupyter Notebooks
* MySQL (InnoDB, LOAD DATA INFILE)
* Data Warehousing (Star Schema)
* ETL Design Patterns (chunking, streaming, batching)

---

## 📓 Notebooks (Pipeline Breakdown)

### 🔹 Data Preparation

* **chunk_demand_and_price.ipynb**
  Splits large datasets into **500K row chunks** for memory-efficient processing.

* **chunk_unpivoted_weather.ipynb**
  Further chunks transformed weather datasets for scalable ingestion.

---

### 🔹 Transformation

* **etl_unpivot_weather.ipynb**
  Converts wide weather data into normalized format using `pandas.melt()` and separates numeric/text values.

---

### 🔹 Staging Layer (High-Speed Ingestion)

* **chunks_to_staging_multi_stream_loader.ipynb**
  Streams chunked files into MySQL using `LOAD DATA LOCAL INFILE` with throughput tracking.

---

### 🔹 Cleaned Layer

* **MULTI-STREAM LOADER (stg → tmp_cleaned).ipynb**
  Transforms staging data into structured format with:

  * timestamp parsing
  * ISO code normalization
  * hash-based deduplication
  * incremental streaming via `raw_id`

---

### 🔹 Fact Table Load

* **fact_tables_loader.ipynb**
  Loads fact tables using:

  * batch inserts
  * in-memory dimension lookups (dictionary mapping)
  * referential integrity checks

---

### 🔹 Enterprise Pipeline (Final System)

* **FINAL ENTERPRISE ETL FACT LOADER + DIAGNOSTIC CSV MODULE (INTEGRATED).ipynb**
  Fully integrated pipeline with:

  * progress tracking (rows/sec, ETA)
  * batch + pipeline metadata
  * data quality diagnostics (invalid keys, duplicates, missing timestamps)
  * CSV audit outputs

---

### 🔹 Streaming Optimisation

* **stream_demand_and_price.ipynb**
  Implements efficient streaming logic for large datasets and incremental loads.

---

## 📊 Data Model

### Fact Tables

* `fact_demand`
* `fact_price`

### Dimensions

* `dim_time`
* `dim_country`

---

## ⚡ Performance & Optimisation

* Chunking (**500K rows per file**)
* Streaming ingestion (no full dataset loads in memory)
* Dictionary-based joins (**O(1) lookups**)
* Bulk inserts (`executemany`)
* Incremental loading via `raw_id`
* Throughput monitoring (rows/sec, ETA)

---

## 🔐 Data Engineering Features

* Batch tracking (`batch_id`)
* Pipeline versioning (`pipeline_id`)
* Idempotent loads (`INSERT IGNORE`)
* Data quality validation layer
* Audit logging + CSV diagnostics
* Error handling & recovery patterns

---

## 📂 Project Structure

```
notebooks/
  ├── chunk_demand_and_price.ipynb
  ├── chunk_unpivoted_weather.ipynb
  ├── chunks_to_staging_multi_stream_loader.ipynb
  ├── etl_unpivot_weather.ipynb
  ├── fact_tables_loader.ipynb
  ├── FINAL ENTERPRISE ETL FACT LOADER + DIAGNOSTIC CSV MODULE (INTEGRATED).ipynb
  ├── MULTI-STREAM LOADER (stg → tmp_cleaned).ipynb
  ├── stream_demand_and_price.ipynb

data/
  ├── demand_chunks/
  ├── price_chunks/
  ├── weather_chunks/

etl_diagnostics/
```

---

## ▶️ How to Run

Execute notebooks in order:

1. Chunk raw datasets
2. Unpivot weather data
3. Load staging tables
4. Transform to cleaned layer
5. Load fact tables
6. Run final pipeline with diagnostics

---

## 🧩 Key Takeaways

* Designed and optimised a **scalable ETL pipeline**
* Worked with **large, real-world datasets**
* Applied **data warehousing principles (star schema)**
* Implemented **streaming + chunk-based processing**
* Added **observability (logging, metrics, diagnostics)**

---

## 📌 Author

Data engineering project focused on **scalability, performance optimisation, and production-style ETL design**.
