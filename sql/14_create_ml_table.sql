USE VehicleServiceAnalytics;
GO

/* ============================================================
   TASK 3 — Create ML Table
   ============================================================ */

DROP TABLE IF EXISTS ml.vehicle_service_features;
GO

CREATE TABLE ml.vehicle_service_features
(
    customer_id INT NOT NULL,
    manufacturer VARCHAR(100) NULL,
    vehicle_model VARCHAR(100) NULL,
    vehicle_type VARCHAR(50) NULL,
    city VARCHAR(100) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    problem_category VARCHAR(100) NOT NULL,
    solution_category VARCHAR(100) NOT NULL,
    service_count INT NOT NULL,
    multiple_services_flag BIT NOT NULL,
    model_known_flag BIT NOT NULL,

    CONSTRAINT PK_ml_vehicle_service_features
        PRIMARY KEY (customer_id)
);
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'ml'
  AND TABLE_NAME = 'vehicle_service_features'
ORDER BY ORDINAL_POSITION;
GO


SELECT
    kc.name AS constraint_name,
    c.name AS column_name
FROM sys.key_constraints AS kc
INNER JOIN sys.index_columns AS ic
    ON kc.parent_object_id = ic.object_id
    AND kc.unique_index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE kc.parent_object_id = OBJECT_ID('ml.vehicle_service_features')
  AND kc.type = 'PK';
GO