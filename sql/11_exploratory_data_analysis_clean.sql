USE VehicleServiceAnalytics;
GO

/*
=========================================================
PHASE 9 - EXPLORATORY DATA ANALYSIS
=========================================================

Purpose:
Explore the engineered customer-level feature table
before final validation and ML-ready dataset publication.

Source:
    analytics.vehicle_service_features

Supporting Sources:
    stg.vehicle_service_clean
    stg.vehicle_company_mapping
    raw.vehicle_service

EDA Principle:
This script is READ-ONLY.
No source or analytical tables are modified.
*/

---------------------------------------------------------
-- 9.1 Total Customers
---------------------------------------------------------

SELECT
    COUNT(*) AS total_customers
FROM analytics.vehicle_service_features;
GO


---------------------------------------------------------
-- 9.2 Service Count Distribution
---------------------------------------------------------

SELECT
    service_count,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY service_count
ORDER BY service_count;
GO


---------------------------------------------------------
-- 9.3 Multiple-Service Customer Distribution
---------------------------------------------------------

SELECT
    multiple_services_flag,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY multiple_services_flag
ORDER BY multiple_services_flag;
GO


---------------------------------------------------------
-- 9.4 Manufacturer Distribution
---------------------------------------------------------

SELECT
    manufacturer,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY manufacturer
ORDER BY customer_count DESC;
GO


---------------------------------------------------------
-- 9.5 Manufacturer Mapping Quality
---------------------------------------------------------

-- 9.5.1 Unmapped Vehicle Company Values

SELECT
    source_vehicle_company,
    COUNT(*) AS customer_count
FROM stg.vehicle_service_clean
WHERE manufacturer IS NULL
GROUP BY source_vehicle_company
ORDER BY customer_count DESC, source_vehicle_company;
GO


-- 9.5.2 Manufacturer Mapping Coverage

SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN manufacturer IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS mapped_customers,

    SUM(
        CASE
            WHEN manufacturer IS NULL THEN 1
            ELSE 0
        END
    ) AS unmapped_customers,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN manufacturer IS NOT NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS mapped_percentage,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN manufacturer IS NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS unmapped_percentage

FROM stg.vehicle_service_clean;
GO


-- 9.5.3 Count Distinct Unmapped Vehicle Company Values

SELECT
    COUNT(*) AS unmapped_distinct_values
FROM
(
    SELECT DISTINCT
        source_vehicle_company
    FROM stg.vehicle_service_clean
    WHERE manufacturer IS NULL
) AS unmapped_values;
GO


-- 9.5.4 Review All Unmapped Vehicle Company Values

SELECT
    ROW_NUMBER() OVER
    (
        ORDER BY source_vehicle_company
    ) AS value_number,

    source_vehicle_company,
    COUNT(*) AS customer_count

FROM stg.vehicle_service_clean
WHERE manufacturer IS NULL
GROUP BY source_vehicle_company
ORDER BY value_number;
GO


-- 9.5.5 Compare Cleaned Values Against Mapping Table

SELECT DISTINCT
    v.source_vehicle_company
FROM stg.vehicle_service_clean AS v
LEFT JOIN stg.vehicle_company_mapping AS m
    ON v.source_vehicle_company = m.source_value
WHERE m.source_value IS NULL
ORDER BY v.source_vehicle_company;
GO


-- 9.5.6 Review Standardized Vehicle Company Mapping

SELECT
    source_value,
    manufacturer_standard,
    model_standard,
    vehicle_type
FROM stg.vehicle_company_mapping
ORDER BY
    manufacturer_standard,
    model_standard,
    source_value;
GO


---------------------------------------------------------
-- 9.6 Malformed Vehicle Company Investigation
---------------------------------------------------------

-- Identify source values containing commas.
-- These may indicate CSV parsing issues.

SELECT
    customer_id_raw,
    city_raw,
    state_raw,
    service_history_raw,
    common_problem_raw,
    solution_used_raw,
    vehicle_company_raw
FROM raw.vehicle_service
WHERE vehicle_company_raw LIKE '%,%';
GO


-- Investigate the two known malformed records
-- discovered during EDA.

SELECT
    customer_id,
    city,
    state_name,
    service_history,
    common_problem,
    solution_used,
    source_vehicle_company,
    manufacturer,
    vehicle_model,
    vehicle_type
FROM stg.vehicle_service_clean
WHERE source_vehicle_company IN
(
    'Check coolant level; flush radiator; replace thermostat., Hero Motrocrop',
    'Inspect pads/rotors; replace if worn., Mercedes-Benz'
);
GO


-- Inspect the corresponding original RAW records.

SELECT
    customer_id_raw,
    city_raw,
    state_raw,
    service_history_raw,
    common_problem_raw,
    solution_used_raw,
    vehicle_company_raw
FROM raw.vehicle_service
WHERE customer_id_raw IN ('59', '60');
GO


---------------------------------------------------------
-- 9.7 Problem Category Distribution
---------------------------------------------------------

SELECT
    problem_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY problem_category
ORDER BY customer_count DESC;
GO


---------------------------------------------------------
-- 9.8 Solution Category Distribution
---------------------------------------------------------

SELECT
    solution_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY solution_category
ORDER BY customer_count DESC;
GO


---------------------------------------------------------
-- 9.9 Problem-Solution Relationship
---------------------------------------------------------

SELECT
    problem_category,
    solution_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    problem_category,
    solution_category
ORDER BY
    problem_category,
    customer_count DESC;
GO


---------------------------------------------------------
-- 9.10 Manufacturer vs Problem Category
---------------------------------------------------------

SELECT
    manufacturer,
    problem_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
WHERE manufacturer IS NOT NULL
GROUP BY
    manufacturer,
    problem_category
ORDER BY
    manufacturer,
    customer_count DESC;
GO


---------------------------------------------------------
-- 9.11 Manufacturer Service Count
---------------------------------------------------------

SELECT
    manufacturer,

    AVG(
        CAST(service_count AS DECIMAL(10,2))
    ) AS avg_service_count,

    MIN(service_count) AS min_service_count,

    MAX(service_count) AS max_service_count,

    COUNT(*) AS customer_count

FROM analytics.vehicle_service_features
WHERE manufacturer IS NOT NULL
GROUP BY manufacturer
ORDER BY avg_service_count DESC;
GO


---------------------------------------------------------
-- 9.12 Vehicle Model Distribution
---------------------------------------------------------

SELECT
    vehicle_model,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
WHERE vehicle_model IS NOT NULL
GROUP BY vehicle_model
ORDER BY
    customer_count DESC,
    vehicle_model;
GO


---------------------------------------------------------
-- 9.13 Model Availability by Manufacturer
---------------------------------------------------------

SELECT
    manufacturer,
    model_known_flag,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
WHERE manufacturer IS NOT NULL
GROUP BY
    manufacturer,
    model_known_flag
ORDER BY
    manufacturer,
    model_known_flag DESC;
GO


---------------------------------------------------------
-- 9.14 Service Count Summary
---------------------------------------------------------

SELECT
    MIN(service_count) AS min_service_count,
    MAX(service_count) AS max_service_count,
    AVG(
        CAST(service_count AS DECIMAL(10,2))
    ) AS avg_service_count,
    COUNT(*) AS total_customers
FROM analytics.vehicle_service_features;
GO


---------------------------------------------------------
-- 9.15 Problem-Solution Path Distribution
---------------------------------------------------------

SELECT
    problem_solution_path,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY problem_solution_path
ORDER BY customer_count DESC;
GO

---------------------------------------------------------
-- 9.16 Cross-Layer Customer Count Check
---------------------------------------------------------

SELECT
    'RAW' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT TRY_CONVERT(INT, TRIM(customer_id_raw))) AS distinct_customer_count
FROM raw.vehicle_service

UNION ALL

SELECT
    'STAGING' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_count
FROM stg.vehicle_service_clean

UNION ALL

SELECT
    'ANALYTICS FEATURES' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_count
FROM analytics.vehicle_service_features;
GO