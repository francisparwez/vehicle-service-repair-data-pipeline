USE VehicleServiceAnalytics;
GO

-- 01 INVALID CUSTOMER IDS
SELECT *
FROM raw.vehicle_service
WHERE TRY_CONVERT(INT, TRIM(customer_id_raw)) IS NULL;

-- 02 EXACT DUPLICATE RECORDS
SELECT
    customer_id_raw,
    city_raw,
    state_raw,
    service_history_raw,
    common_problem_raw,
    solution_used_raw,
    vehicle_company_raw,
    COUNT(*) AS occurrence_count
FROM raw.vehicle_service
GROUP BY
    customer_id_raw,
    city_raw,
    state_raw,
    service_history_raw,
    common_problem_raw,
    solution_used_raw,
    vehicle_company_raw
HAVING COUNT(*) > 1;

-- 03 Duplicate Business Keys

SELECT
    customer_id_raw,
    COUNT(*) AS occurrence_count
FROM raw.vehicle_service
GROUP BY customer_id_raw
HAVING COUNT(*) > 1;

-- 04 Leading / Trailing Whitespace

SELECT
    SUM(
        CASE
            WHEN city_raw <> TRIM(city_raw)
            THEN 1 ELSE 0
        END
    ) AS city_whitespace_issues,

    SUM(
        CASE
            WHEN state_raw <> TRIM(state_raw)
            THEN 1 ELSE 0
        END
    ) AS state_whitespace_issues,

    SUM(
        CASE
            WHEN service_history_raw <> TRIM(service_history_raw)
            THEN 1 ELSE 0
        END
    ) AS service_history_whitespace_issues,

    SUM(
        CASE
            WHEN common_problem_raw <> TRIM(common_problem_raw)
            THEN 1 ELSE 0
        END
    ) AS problem_whitespace_issues,

    SUM(
        CASE
            WHEN solution_used_raw <> TRIM(solution_used_raw)
            THEN 1 ELSE 0
        END
    ) AS solution_whitespace_issues,

    SUM(
        CASE
            WHEN vehicle_company_raw <> TRIM(vehicle_company_raw)
            THEN 1 ELSE 0
        END
    ) AS company_whitespace_issues

FROM raw.vehicle_service;

-- 05 WHY THIS PROBLEM OCCURS
-- Before
SELECT
    city_raw,
    COUNT(*) AS records
FROM raw.vehicle_service
GROUP BY city_raw;

-- After
SELECT
    TRIM(city_raw) AS city,
    COUNT(*) AS records
FROM raw.vehicle_service
GROUP BY TRIM(city_raw);

-- 06 Inconsistent Categorical Values
SELECT DISTINCT
    TRIM(vehicle_company_raw) AS vehicle_company
FROM raw.vehicle_service
ORDER BY vehicle_company;