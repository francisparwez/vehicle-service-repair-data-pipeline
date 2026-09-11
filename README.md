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

The complete data transformation workflow is implemented using **T-SQL and SQL Server**.

---

## Project Objective

The source dataset contains vehicle service and repair records collected from a Kaggle dataset.

The objective is to build a reproducible SQL pipeline that can:

1. Ingest the raw CSV data into SQL Server.
2. Preserve the original source data in a dedicated raw layer.
3. Profile and audit the incoming data.
4. Identify and document data-quality issues.
5. Clean and standardize inconsistent data.
6. Transform semi-structured fields into structured relational data.
7. Engineer analytical and machine-learning features.
8. Validate the transformed data.
9. Produce a final dataset suitable for downstream analytics or machine-learning workflows.

---

## Technology Stack

- **SQL Server**
- **T-SQL**
- **SQL Server Management Studio (SSMS)**
- **CSV**
- **Git / GitHub**

---

## Pipeline Architecture

The project follows a layered data architecture designed to separate ingestion, transformation, analytics, and machine-learning preparation.

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

## Phase 3 — Raw Table Creation & CSV Ingestion

**Status: Complete**

### Raw Table Design

The raw source table was created under the `raw` schema.

The raw table contains the seven source columns from the CSV dataset. All source fields are stored as `VARCHAR` values so that the original source representation can be preserved before validation, cleansing, or transformation.

### Raw Table Verification

After creating the raw table, the script verifies the table structure using
`INFORMATION_SCHEMA.COLUMNS` to confirm that the expected columns and data
types are present.

A row-count check is also performed to confirm that the raw table is empty
before CSV ingestion.

```sql
CREATE TABLE raw.vehicle_service
(
    customer_id_raw       VARCHAR(100) NULL,
    city_raw              VARCHAR(255) NULL,
    state_raw             VARCHAR(255) NULL,
    service_history_raw   VARCHAR(1000) NULL,
    common_problem_raw    VARCHAR(500) NULL,
    solution_used_raw     VARCHAR(500) NULL,
    vehicle_company_raw   VARCHAR(500) NULL
);
GO
```

### Raw Table Design Principles

The raw table deliberately preserves the source data before cleaning or transformation.

The source `CUSTOMER ID` is stored as:

```text
customer_id_raw
```

and remains a `VARCHAR` during the raw ingestion stage.

This prevents assumptions about the quality or validity of the source identifier before the data-quality audit has been completed.

The raw layer is intended to preserve the source representation so that subsequent profiling, auditing, cleansing, and transformation can be performed in downstream layers.

### Raw Table Structure

| Column                | Purpose                                  |
| --------------------- | ---------------------------------------- |
| `customer_id_raw`     | Original customer identifier from source |
| `city_raw`            | Original city value                      |
| `state_raw`           | Original state value                     |
| `service_history_raw` | Original service history                 |
| `common_problem_raw`  | Original service problem                 |
| `solution_used_raw`   | Original solution                        |
| `vehicle_company_raw` | Original vehicle company                 |

### CSV Ingestion

The Kaggle CSV is loaded into the raw table using SQL Server's `BULK INSERT` command.

Before loading the dataset, the raw table is truncated to ensure that previous test or import data does not remain in the table.

```sql
TRUNCATE TABLE raw.vehicle_service;
```

The CSV is then imported using:

```sql
BULK INSERT raw.vehicle_service
FROM 'C:\path\to\vehicle-service_repair.csv'
WITH
(
    DATAFILETYPE = 'char',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
```

The import configuration uses:

- `FIRSTROW = 2` to skip the CSV header.
- `FIELDTERMINATOR = ','` to identify comma-separated columns.
- `ROWTERMINATOR = '0x0a'` to identify row boundaries.
- `DATAFILETYPE = 'char'` to read the source as character data.
- `TABLOCK` to apply a table-level lock during loading.

No data cleaning or business transformation is performed during ingestion.

The purpose of this stage is to load the source data into the raw layer so that profiling and data-quality auditing can be performed before transformations are applied.

### Load Verification

After the CSV import, the number of records loaded into the raw table is verified using:

```sql
SELECT COUNT(*) AS loaded_rows
FROM raw.vehicle_service;
```

The loaded raw records can also be inspected using:

```sql
SELECT *
FROM raw.vehicle_service;
```

The ingestion script does not perform any data cleaning or transformation. It only loads the CSV values into the raw table.

The loaded dataset is available inside:

```text
VehicleServiceAnalytics
|
+-- raw
    |
    +-- vehicle_service
```

---

## Phase 4 — Data Profiling & Quality Audit

**Status: Complete**

After ingestion, the raw dataset was profiled and audited before applying any cleaning or transformation.

This phase focuses on answering:

> What is wrong with the source data?

rather than immediately modifying the data.

### Data Profiling

The initial profiling stage establishes a baseline understanding of the raw dataset.

The current profiling script checks:

- Total row count
- Missing customer IDs
- Missing cities
- Missing states
- Missing service history
- Missing common problems
- Missing solutions
- Missing vehicle company values

Blank values are treated as missing after applying `TRIM()` and `NULLIF()` to the source fields.

The profiling results provide the initial baseline for the subsequent data-quality audit.

### Data Quality Audit

The data-quality audit investigates specific issues identified during
the initial profiling stage.

The current audit covers:

- Invalid customer identifiers
- Exact duplicate records
- Duplicate customer identifiers
- Leading and trailing whitespace
- Categorical inconsistencies
- The effect of whitespace on categorical grouping

### Audit Checks

#### Invalid Customer IDs

Customer identifiers are tested using `TRY_CONVERT(INT, ...)` to identify
values that cannot be converted into valid integer identifiers.

#### Exact Duplicate Records

All source columns are compared together to identify records where the
complete source row occurs more than once.

#### Duplicate Customer IDs

Customer IDs are independently checked for multiple occurrences. This
helps distinguish repeated business identifiers from exact duplicate
records.

#### Whitespace Issues

Text columns are compared against their `TRIM()` values to identify
leading or trailing whitespace.

The audit covers:

- City
- State
- Service history
- Common problem
- Solution used
- Vehicle company

#### Categorical Consistency

Distinct trimmed vehicle-company values are reviewed to identify
inconsistent categorical representations.

A before-and-after comparison using `TRIM()` is also performed to show
how whitespace can create duplicate categorical values.

No cleaning transformations are applied directly to the raw source
layer. The audit only identifies and analyzes quality issues.

### Key Data Quality Dimensions

| Dimension    | Audit Focus                             |
| ------------ | --------------------------------------- |
| Completeness | Missing and blank values                |
| Uniqueness   | Duplicate records and identifiers       |
| Validity     | Invalid customer identifiers            |
| Consistency  | Conflicting categorical representations |
| Conformity   | Whitespace and formatting consistency   |

No cleaning transformations are applied directly to the raw source layer.

The findings from this phase will be used to define the transformation and cleansing rules implemented in the staging layer.

---

# Repository Structure

The project is being developed using the following structure:

```text
vehicle-service-repair-data-pipeline/

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
│   └── 05_data_quality_audit.sql
│
└── README.md
```

> **Note:** The repository structure reflects the complete planned pipeline. SQL scripts and documentation are being added incrementally as each phase is completed.

---

# Pipeline Stages

| Phase | Description                        | Status      |
| ----- | ---------------------------------- | ----------- |
| 1     | Database creation                  | ✅ Complete |
| 2     | Schema architecture                | ✅ Complete |
| 3     | Raw table creation & CSV ingestion | ✅ Complete |
| 4     | Data profiling & quality audit     | ✅ Complete |
| 5     | Data cleansing & standardization   | ⏳ Planned  |
| 6     | Data transformation                | ⏳ Planned  |
| 7     | Data normalization                 | ⏳ Planned  |
| 8     | Feature engineering                | ⏳ Planned  |
| 9     | Exploratory data analysis          | ⏳ Planned  |
| 10    | Data validation                    | ⏳ Planned  |
| 11    | ML-ready dataset publication       | ⏳ Planned  |
| 12    | Final documentation                | ⏳ Planned  |

---

## Skills Demonstrated

### SQL & T-SQL

- T-SQL
- SQL Server
- CTEs
- Window functions
- Conditional logic
- String manipulation
- Aggregations
- Data type conversion

### Data Engineering

- ETL pipeline design
- CSV ingestion
- Raw data layer architecture
- Data profiling
- Data-quality auditing
- Data lineage
- Layered database architecture

### Data Quality

- Missing-value detection
- Duplicate detection
- Categorical consistency
- Data-type validation
- Formatting validation
- Invalid-value detection

### Engineering Practices

- Reproducible SQL scripts
- Layered database architecture
- Separation of raw and transformed data
- Documentation
- Git/GitHub workflow

---

# Project Status

🚧 **Currently in development**

## Completed

- SQL Server database creation
- Layered schema architecture
- Raw table design
- Raw CSV ingestion using `BULK INSERT`
- Raw table load verification
- Data profiling
- Data-quality audit

## Next

**Phase 5 — Data Cleansing & Standardization**

The next stage will use the findings from the data-quality audit to develop controlled cleansing and transformation rules.

The raw dataset will remain unchanged while cleaned data is produced in the staging layer.

---

# Future Pipeline

As development continues, the project will progress through:

```text
Phase 5
Data Cleansing & Standardization
        │
        ▼
Phase 6
Data Transformation
        │
        ▼
Phase 7
Data Normalization
        │
        ▼
Phase 8
Feature Engineering
        │
        ▼
Phase 9
Exploratory Data Analysis
        │
        ▼
Phase 10
Data Validation
        │
        ▼
Phase 11
ML-Ready Dataset Publication
        │
        ▼
Phase 12
Final Documentation
```

The final objective is a reproducible SQL Server pipeline that demonstrates the complete progression from raw source data to a validated analytical and machine-learning-ready dataset.

---

# Vehicle Service Repair SQL Data Pipeline
