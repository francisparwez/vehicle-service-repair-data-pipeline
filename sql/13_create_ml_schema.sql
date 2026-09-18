USE VehicleServiceAnalytics;
GO

/* ============================================================
   TASK 1 — Create ML Schema
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'ml'
)
BEGIN
    EXEC('CREATE SCHEMA ml');
END;
GO

SELECT
    name AS schema_name
FROM sys.schemas
WHERE name = 'ml';
GO

SELECT
    SCHEMA_NAME(schema_id) AS schema_name
FROM sys.schemas
WHERE name = 'ml';
GO


SELECT TOP 5
    customer_id,
    manufacturer,
    vehicle_model,
    problem_category,
    solution_category,
    service_count,
    multiple_services_flag,
    model_known_flag
FROM analytics.vehicle_service_features;
GO


SELECT TOP 5
    customer_id,
    city,
    state_name,
    vehicle_type
FROM stg.vehicle_service_clean;
GO

/* ============================================================
   TASK 2A — Check ML Feature Coverage
   ============================================================ */

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN manufacturer IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_manufacturer,

    SUM(
        CASE
            WHEN vehicle_model IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_vehicle_model,

    SUM(
        CASE
            WHEN vehicle_type IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_vehicle_type,

    SUM(
        CASE
            WHEN city IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_city,

    SUM(
        CASE
            WHEN state_name IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_state,

    SUM(
        CASE
            WHEN problem_category IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_problem_category,

    SUM(
        CASE
            WHEN solution_category IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_solution_category

FROM
(
    SELECT
        a.manufacturer,
        a.vehicle_model,
        s.vehicle_type,
        s.city,
        s.state_name,
        a.problem_category,
        a.solution_category
    FROM analytics.vehicle_service_features AS a
    INNER JOIN stg.vehicle_service_clean AS s
        ON a.customer_id = s.customer_id
) AS feature_check;
GO