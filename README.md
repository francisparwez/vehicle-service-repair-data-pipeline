# Vehicle Service & Repair Data Pipeline — T-SQL

## Project Overview

This project is an end-to-end **T-SQL data engineering and analytics pipeline** built using SQL Server.

The goal is to take raw vehicle service and repair data from a CSV source and progressively transform it into a **clean, validated, structured, and ML-ready dataset**.

The project focuses on demonstrating practical data engineering workflows, including:

- CSV data ingestion
- Data profiling and auditing
- Data quality assessment
- Data cleansing and standardization
- Data transformation
- Relational data normalization
- Feature engineering
- Exploratory data analysis
- Data validation
- Preparation of a final ML-ready dataset

The entire data transformation workflow is implemented using **T-SQL**.

---

## Project Objective

The source dataset contains vehicle service and repair records collected from a Kaggle dataset.

The objective is to build a reproducible SQL pipeline that can:

1. Ingest the raw CSV data into SQL Server.
2. Preserve the original source data in an immutable raw layer.
3. Identify and document data-quality issues.
4. Clean and standardize inconsistent data.
5. Transform semi-structured fields into relational structures.
6. Engineer analytical and machine-learning features.
7. Validate the transformed data.
8. Produce a final dataset suitable for downstream analytics or machine-learning workflows.

---

## Technology Stack

- **SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **CSV**
- **Git / GitHub**

---

## Pipeline Architecture

The project follows a layered data architecture:

```text
Kaggle CSV
    │
    ▼
┌──────────────┐
│     RAW      │
│ Source Data  │
└──────────────┘
    │
    ▼
 Data Profiling
 & Quality Audit
    │
    ▼
┌──────────────┐
│     STG      │
│ Cleaned Data │
└──────────────┘
    │
    ▼
 Transformation
 & Normalization
    │
    ▼
┌──────────────┐
│  ANALYTICS   │
│ Analytical   │
│   Models     │
└──────────────┘
    │
    ▼
 Feature Engineering
    │
    ▼
┌──────────────┐
│      ML      │
│ Feature Set  │
└──────────────┘
    │
    ▼
Validated ML-Ready Dataset
```

---

# Current Progress

## Phase 1 — Database Setup ✅

The SQL Server database has been created:

```text
VehicleServiceAnalytics
```

The database provides the foundation for the complete data pipeline.

### Database Creation

The database is created programmatically using T-SQL rather than relying on manual SSMS configuration.

```sql
USE master;
GO

IF DB_ID('VehicleServiceAnalytics') IS NULL
BEGIN
    CREATE DATABASE VehicleServiceAnalytics;
END;
GO

USE VehicleServiceAnalytics;
GO
```

This makes the project reproducible and allows the database environment to be recreated from the repository.

---

## Phase 2 — Schema Architecture ✅

The database has been divided into four logical schemas:

| Schema      | Purpose                                                          |
| ----------- | ---------------------------------------------------------------- |
| `raw`       | Stores the original source data without business transformations |
| `stg`       | Contains cleaned and transformed staging data                    |
| `analytics` | Contains normalized structures designed for analysis             |
| `ml`        | Contains final machine-learning features and datasets            |

The schemas are created using T-SQL:

```sql
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'raw'
)
    EXEC('CREATE SCHEMA raw');
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'stg'
)
    EXEC('CREATE SCHEMA stg');
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'analytics'
)
    EXEC('CREATE SCHEMA analytics');
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'ml'
)
    EXEC('CREATE SCHEMA ml');
GO
```

### Why a Layered Architecture?

Separating the pipeline into logical layers provides:

- **Data lineage** — the original source remains available.
- **Traceability** — transformations can be traced back to raw data.
- **Data quality control** — raw and cleaned data can be compared.
- **Reproducibility** — transformations can be rerun.
- **Separation of concerns** — ingestion, transformation, analysis, and ML preparation remain distinct.
- **Maintainability** — individual pipeline stages can be modified without altering the source layer.

---

# Repository Structure

The project is being developed using the following structure:

```text
Vehicle-Service-Repair-SQL-Data-Pipeline/
│
├── data/
│   └── vehicle-service_repair.csv
│
├── sql/
│   ├── 00_create_database.sql
│   ├── 01_create_schemas.sql
│   ├── 02_create_raw_tables.sql
│   ├── 03_load_csv.sql
│   ├── 04_data_profiling.sql
│   ├── 05_data_quality_audit.sql
│   ├── 06_create_clean_tables.sql
│   ├── 07_clean_transform.sql
│   ├── 08_normalize_service_history.sql
│   ├── 09_feature_engineering.sql
│   ├── 10_data_validation.sql
│   ├── 11_eda.sql
│   └── 12_publish_ml_dataset.sql
│
├── docs/
│   ├── data_dictionary.md
│   ├── data_quality_report.md
│   ├── transformation_rules.md
│   └── project_notes.md
│
└── README.md
```

> **Note:** The repository structure represents the planned pipeline. Individual scripts and documentation will be added as each project phase is completed.

---

# Planned Pipeline Stages

| Phase | Description               | Status      |
| ----- | ------------------------- | ----------- |
| 1     | Database creation         | ✅ Complete |
| 2     | Schema architecture       | ✅ Complete |
| 3     | Raw table creation        | ⏳ Planned  |
| 4     | CSV ingestion             | ⏳ Planned  |
| 5     | Data profiling            | ⏳ Planned  |
| 6     | Data-quality audit        | ⏳ Planned  |
| 7     | Data cleansing            | ⏳ Planned  |
| 8     | Data transformation       | ⏳ Planned  |
| 9     | Data normalization        | ⏳ Planned  |
| 10    | Feature engineering       | ⏳ Planned  |
| 11    | Exploratory data analysis | ⏳ Planned  |
| 12    | Data validation           | ⏳ Planned  |
| 13    | ML-ready dataset          | ⏳ Planned  |
| 14    | Final documentation       | ⏳ Planned  |

---

# Skills Demonstrated

By completion, this project will demonstrate practical experience with:

- T-SQL
- SQL Server
- ETL pipeline design
- CSV ingestion
- Data profiling
- Data-quality auditing
- Data cleansing
- Data validation
- Data transformation
- Data normalization
- CTEs
- Window functions
- `STRING_SPLIT`
- `CROSS APPLY`
- Reference/mapping tables
- Feature engineering
- Exploratory data analysis
- Data lineage
- Relational data modeling
- Git/GitHub workflow

---

# Project Status

🚧 **Currently in development**

Completed:

- Database creation
- Layered schema architecture

Next:

**Phase 3 — Raw table creation and CSV ingestion**

The raw ingestion layer will preserve the source dataset before any cleaning or transformation is applied.
