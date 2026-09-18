USE VehicleServiceAnalytics;
GO

/* ============================================================
   TASK 6 — ML Readiness Checks
   ============================================================ */

SELECT
    SUM(
        CASE
            WHEN customer_id IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_customer_id,

    SUM(
        CASE
            WHEN city IS NULL
              OR TRIM(city) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_city,

    SUM(
        CASE
            WHEN state_name IS NULL
              OR TRIM(state_name) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_state,

    SUM(
        CASE
            WHEN problem_category IS NULL
              OR TRIM(problem_category) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_problem_category,

    SUM(
        CASE
            WHEN solution_category IS NULL
              OR TRIM(solution_category) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_solution_category,

    SUM(
        CASE
            WHEN service_count IS NULL
              OR service_count <= 0
            THEN 1
            ELSE 0
        END
    ) AS invalid_service_count
FROM ml.vehicle_service_features;
GO


SELECT
    SUM(
        CASE
            WHEN multiple_services_flag NOT IN (0, 1)
              OR multiple_services_flag IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_multiple_services_flag,

    SUM(
        CASE
            WHEN model_known_flag NOT IN (0, 1)
              OR model_known_flag IS NULL
            THEN 1
            ELSE 0
        END
    ) AS invalid_model_known_flag
FROM ml.vehicle_service_features;
GO


SELECT
    COUNT(*) AS customers_with_vehicle_information,
    SUM(
        CASE
            WHEN manufacturer IS NOT NULL
              OR vehicle_model IS NOT NULL
              OR vehicle_type IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS customers_with_partial_or_complete_vehicle_information
FROM ml.vehicle_service_features;
GO


/* ============================================================
   TASK 7 — Final ML Dataset Profile
   ============================================================ */

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT manufacturer) AS unique_manufacturers,
    COUNT(DISTINCT vehicle_model) AS unique_vehicle_models,
    COUNT(DISTINCT vehicle_type) AS unique_vehicle_types,
    COUNT(DISTINCT city) AS unique_cities,
    COUNT(DISTINCT state_name) AS unique_states,
    COUNT(DISTINCT problem_category) AS unique_problem_categories,
    COUNT(DISTINCT solution_category) AS unique_solution_categories
FROM ml.vehicle_service_features;
GO


SELECT
    problem_category,
    COUNT(*) AS customer_count
FROM ml.vehicle_service_features
GROUP BY problem_category
ORDER BY customer_count DESC;
GO


SELECT
    solution_category,
    COUNT(*) AS customer_count
FROM ml.vehicle_service_features
GROUP BY solution_category
ORDER BY customer_count DESC;
GO


SELECT
    manufacturer,
    COUNT(*) AS customer_count
FROM ml.vehicle_service_features
WHERE manufacturer IS NOT NULL
GROUP BY manufacturer
ORDER BY customer_count DESC;
GO

/* ============================================================
   TASK 8 — Final ML Dataset Snapshot
   ============================================================ */

SELECT TOP 10
    customer_id,
    manufacturer,
    vehicle_model,
    vehicle_type,
    city,
    state_name,
    problem_category,
    solution_category,
    service_count,
    multiple_services_flag,
    model_known_flag
FROM ml.vehicle_service_features
ORDER BY customer_id;
GO