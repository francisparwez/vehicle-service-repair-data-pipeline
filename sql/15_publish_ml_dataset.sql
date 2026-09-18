USE VehicleServiceAnalytics;
GO

/* ============================================================
   TASK 4 — Publish ML Dataset
   ============================================================ */

TRUNCATE TABLE ml.vehicle_service_features;
GO

INSERT INTO ml.vehicle_service_features
(
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
)
SELECT
    a.customer_id,
    a.manufacturer,
    a.vehicle_model,
    s.vehicle_type,
    s.city,
    s.state_name,
    a.problem_category,
    a.solution_category,
    a.service_count,
    a.multiple_services_flag,
    a.model_known_flag
FROM analytics.vehicle_service_features AS a
INNER JOIN stg.vehicle_service_clean AS s
    ON a.customer_id = s.customer_id;
GO


SELECT
    COUNT(*) AS ml_row_count,
    COUNT(DISTINCT customer_id) AS ml_unique_customers
FROM ml.vehicle_service_features;
GO

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