USE VehicleServiceAnalytics;
GO

-- 01 ROW COUNT
SELECT COUNT(*) AS total_rows
FROM raw.vehicle_service;

-- 02 COLUMN COMPLETENESS
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN NULLIF(TRIM(customer_id_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_customer_id,

    SUM(CASE WHEN NULLIF(TRIM(city_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_city,

    SUM(CASE WHEN NULLIF(TRIM(state_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_state,

    SUM(CASE WHEN NULLIF(TRIM(service_history_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_service_history,

    SUM(CASE WHEN NULLIF(TRIM(common_problem_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_common_problem,

    SUM(CASE WHEN NULLIF(TRIM(solution_used_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_solution,

    SUM(CASE WHEN NULLIF(TRIM(vehicle_company_raw), '') IS NULL
             THEN 1 ELSE 0 END) AS missing_vehicle_company

FROM raw.vehicle_service;