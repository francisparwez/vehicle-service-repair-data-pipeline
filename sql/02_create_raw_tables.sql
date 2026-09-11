USE VehicleServiceAnalytics;
GO

DROP TABLE IF EXISTS raw.vehicle_service;
GO

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

--- VERIFYING RAW TABLE

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
  AND TABLE_NAME = 'vehicle_service'
ORDER BY ORDINAL_POSITION;

--- CHECKING IF TABLE IS EMPTY

SELECT COUNT(*) AS row_count
FROM raw.vehicle_service;

--- TRUNCATE TABLE BEFORE LOADING CSV DATASET

TRUNCATE TABLE raw.vehicle_service;
GO