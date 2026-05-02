# ⚡ Energy Market Analytics (ETL Pipeline)

## 📌 Overview

This project builds an end-to-end data pipeline that transforms raw electricity demand, pricing, and weather datasets into a structured, analytics-ready data warehouse.

It demonstrates practical experience in data engineering and analytics, integrating **Python, SQL, and Power BI** to deliver a complete solution from ingestion to reporting.

---

## 🏗️ Architecture
Raw CSV Data
↓
Python: Chunking & Unpivoting
↓
MySQL Staging Layer (stg_)
↓
Streaming → Clean Layer (tmp_cleaned_)
↓
Dimensional Model (dim_)
↓
Fact Tables (fact_)
↓
Power BI Dashboard


---

## ⚙️ Tech Stack

- **Python** (Pandas, PyMySQL, MySQL Connector)
- **MySQL** (Relational Data Warehouse)
- **SQL** (Data transformation & modelling)
- **Power BI** (Visualisation & DAX)
- **Jupyter Notebooks** (Pipeline execution)

---

## 🔥 Key Features

### 📊 Scalable Data Processing
- Processed large datasets using **chunking (500,000 rows per batch)**
- Implemented memory-efficient ingestion workflows
- Streamed data incrementally into MySQL

### 🔄 Data Transformation
- Unpivoted wide-format weather datasets into analytical structure
- Standardised datetime formats and country identifiers
- Cleaned and validated raw data prior to loading

### 🏗️ Multi-Stage ETL Pipeline
- **Staging Layer (stg_*)** → raw ingestion
- **Clean Layer (tmp_cleaned_*)** → validated structured data
- **Warehouse Layer (dim_*, fact_*)** → analytics-ready model

### 🧩 Dimensional Data Modelling
Star schema design:
- `fact_demand`
- `fact_price`
- `dim_time`
- `dim_country`
- `dim_city`

Implemented:
- Primary & foreign keys
- Indexing for performance
- Deduplication rules

### 🚀 Streaming & Incremental Loading
- Chunk-based processing for large-scale ingestion
- Incremental loading using `raw_id`
- Optimised batch inserts for performance

### 🧪 Data Quality & Validation
- Row count reconciliation across pipeline layers
- Detected:
  - Missing timestamps
  - Invalid country mappings
  - Duplicate records
- SQL-based validation and diagnostic checks

### ⚡ Performance Optimisation
- Used `LOAD DATA INFILE` for bulk ingestion
- Indexed key columns for query performance
- Monitored throughput and pipeline efficiency

---
## 📂 Project Structure

Energy-market-analytics/
│
├── Notebooks/
│ ├── chunk_demand_and_price.ipynb
│ ├── chunk_unpivoted_weather.ipynb
│ ├── chunks_to_staging_multi_stream_loader.ipynb
│ ├── etl_unpivot_weather.ipynb
│ ├── stream_demand_and_price.ipynb
│ ├── MULTI-STREAM LOADER (stg → tmp_cleaned).ipynb
│ ├── fact_tables_loader.ipynb
│ └── ETL FACT LOADER + DIAGNOSTIC CSV MODULE (INTEGRATED).ipynb
│
├── sql/
│ ├── 3.1_schema_create.sql
│ ├── 3.2_staging_load.sql
│ ├── 3.3_transform_dim.sql
│ ├── 3.4_facts_load.sql
│ └── 4.1_validation_tests.sql
│
├── data/
│ └── (not included – large datasets)
│
└── README.md
---

## 🔄 Pipeline Breakdown

### 1. Data Preparation (Python)
- Chunked large CSV files into manageable parts
- Unpivoted weather datasets using Pandas
- Prepared structured files for database ingestion

### 2. Staging Layer (MySQL)
- Loaded raw data into `stg_*` tables
- Applied initial validation, deduplication, and indexing

### 3. Transformation Layer
- Streamed data into `tmp_cleaned_*` tables
- Applied:
  - Type conversions
  - Data standardisation
  - Hash-based tracking

### 4. Dimensional Modelling
- Built reusable dimensions:
  - Time
  - Country
  - City
- Unified multiple data sources into a consistent schema

### 5. Fact Table Loading
- Populated:
  - `fact_demand`
  - `fact_price`
- Enforced referential integrity and uniqueness constraints

### 6. Validation & Testing
Executed SQL validation scripts to verify:
- Data completeness
- Referential integrity
- Duplicate handling

---

## 📊 Use Cases

- Analyse electricity demand vs pricing trends
- Compare energy markets across countries
- Perform time-series analysis
- Build Power BI dashboards for insights

---

## 🚀 Project Strengths

- End-to-end ETL pipeline (ingestion → warehouse → BI)
- Handles large-scale, real-world datasets
- Industry-standard dimensional modelling
- Integration of Python, SQL, and BI tools
- Strong focus on scalability and performance

---

## 📌 Future Improvements

- Workflow orchestration (e.g. Airflow)
- Cloud deployment (AWS / Azure)
- Real-time or streaming ingestion
- Enhanced Power BI dashboards & KPIs
