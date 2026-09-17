/* ============================================================
   12_DATA_VALIDATION.SQL
   ============================================================ */

USE VehicleServiceAnalytics;
GO


/* ============================================================
   TASK 01 — Validate RAW Row Count
   ============================================================ */

SELECT
    COUNT(*) AS raw_row_count
FROM raw.vehicle_service;
GO


/* ============================================================
   TASK 02 — Validate RAW Customer Count
   ============================================================ */

SELECT
    COUNT(DISTINCT TRY_CONVERT(INT, TRIM(customer_id_raw))) AS raw_unique_customers
FROM raw.vehicle_service;
GO


/* ============================================================
   TASK 03 — Validate RAW Duplicate Records
   ============================================================ */

WITH DuplicateCheck AS
(
    SELECT
        customer_id_raw,
        city_raw,
        state_raw,
        service_history_raw,
        common_problem_raw,
        solution_used_raw,
        vehicle_company_raw,

        ROW_NUMBER() OVER
        (
            PARTITION BY
                customer_id_raw,
                city_raw,
                state_raw,
                service_history_raw,
                common_problem_raw,
                solution_used_raw,
                vehicle_company_raw
            ORDER BY
                (SELECT NULL)
        ) AS duplicate_rank

    FROM raw.vehicle_service
)
SELECT
    COUNT(*) AS duplicate_records
FROM DuplicateCheck
WHERE duplicate_rank > 1;
GO


/* ============================================================
   TASK 04 — Validate STAGING Row Count
   ============================================================ */

SELECT
    COUNT(*) AS staging_row_count
FROM stg.vehicle_service_clean;
GO


/* ============================================================
   TASK 05 — Validate STAGING Customer Uniqueness
   ============================================================ */

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM stg.vehicle_service_clean
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO


/* ============================================================
   TASK 06 — Validate STAGING NULL Customer IDs
   ============================================================ */

SELECT
    COUNT(*) AS missing_customer_ids
FROM stg.vehicle_service_clean
WHERE customer_id IS NULL;
GO


/* ============================================================
   TASK 07 — Validate STAGING Whitespace
   ============================================================ */

SELECT
    COUNT(*) AS whitespace_issues
FROM stg.vehicle_service_clean
WHERE city <> TRIM(city)
   OR state_name <> TRIM(state_name)
   OR common_problem <> TRIM(common_problem)
   OR solution_used <> TRIM(solution_used)
   OR source_vehicle_company <> TRIM(source_vehicle_company);
GO


/* ============================================================
   TASK 08 — Validate STAGING Blank Required Values
   ============================================================ */

SELECT
    SUM(
        CASE
            WHEN NULLIF(TRIM(city), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_city,

    SUM(
        CASE
            WHEN NULLIF(TRIM(state_name), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_state,

    SUM(
        CASE
            WHEN NULLIF(TRIM(common_problem), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_common_problem,

    SUM(
        CASE
            WHEN NULLIF(TRIM(solution_used), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_solution_used

FROM stg.vehicle_service_clean;
GO


/* ============================================================
   TASK 09 — Validate STAGING Manufacturer Mapping
   ============================================================ */

SELECT
    COUNT(*) AS unmapped_manufacturers
FROM stg.vehicle_service_clean
WHERE manufacturer IS NULL
   OR NULLIF(TRIM(manufacturer), '') IS NULL;
GO


/* ============================================================
   TASK 10 — Inspect Unmapped Vehicle Company Values
   ============================================================ */

SELECT
    source_vehicle_company,
    COUNT(*) AS record_count
FROM stg.vehicle_service_clean
WHERE manufacturer IS NULL
GROUP BY source_vehicle_company
ORDER BY record_count DESC,
         source_vehicle_company;
GO


/* ============================================================
   TASK 11 — Validate ANALYTICS Row Count
   ============================================================ */

SELECT
    COUNT(*) AS analytics_row_count
FROM analytics.vehicle_service_features;
GO


/* ============================================================
   TASK 12 — Validate ANALYTICS Customer Uniqueness
   ============================================================ */

SELECT
    customer_id,
    COUNT(*) AS record_count
FROM analytics.vehicle_service_features
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO


/* ============================================================
   TASK 13 — Validate ANALYTICS NULL Customer IDs
   ============================================================ */

SELECT
    COUNT(*) AS missing_customer_ids
FROM analytics.vehicle_service_features
WHERE customer_id IS NULL;
GO


/* ============================================================
   TASK 14 — Validate ANALYTICS Required Features
   ============================================================ */

SELECT

    SUM(
        CASE
            WHEN problem_category IS NULL
              OR NULLIF(TRIM(problem_category), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_problem_category,

    SUM(
        CASE
            WHEN solution_category IS NULL
              OR NULLIF(TRIM(solution_category), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_solution_category,

    SUM(
        CASE
            WHEN service_count IS NULL
              OR service_count <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_service_count,

    SUM(
        CASE
            WHEN multiple_services_flag IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_multiple_services_flag,

    SUM(
        CASE
            WHEN manufacturer IS NULL
              OR NULLIF(TRIM(manufacturer), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_manufacturer,

    SUM(
        CASE
            WHEN customer_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_customer_id

FROM analytics.vehicle_service_features;
GO


/* ============================================================
   TASK 15 — Validate ANALYTICS Multiple-Service Flag
   ============================================================ */

SELECT
    COUNT(*) AS invalid_multiple_service_flags
FROM analytics.vehicle_service_features
WHERE
    (
        service_count > 1
        AND multiple_services_flag <> 1
    )
    OR
    (
        service_count <= 1
        AND multiple_services_flag <> 0
    );
GO


/* ============================================================
   TASK 16 — Validate ANALYTICS Model Flag
   ============================================================ */

SELECT
    COUNT(*) AS invalid_model_flags
FROM analytics.vehicle_service_features
WHERE
    (
        vehicle_model IS NOT NULL
        AND NULLIF(TRIM(vehicle_model), '') IS NOT NULL
        AND model_known_flag <> 1
    )
    OR
    (
        (
            vehicle_model IS NULL
            OR NULLIF(TRIM(vehicle_model), '') IS NULL
        )
        AND model_known_flag <> 0
    );
GO


/* ============================================================
   TASK 17 — Validate Service History Customer Coverage
   ============================================================ */

SELECT
    COUNT(*) AS customers_missing_service_history
FROM stg.vehicle_service_clean AS s
LEFT JOIN
(
    SELECT DISTINCT
        customer_id
    FROM analytics.customer_service_history
) AS h
    ON s.customer_id = h.customer_id
WHERE h.customer_id IS NULL;
GO


/* ============================================================
   TASK 18 — Validate Service History Referential Integrity
   ============================================================ */

SELECT
    COUNT(*) AS orphan_service_history_records
FROM analytics.customer_service_history AS h
LEFT JOIN stg.vehicle_service_clean AS s
    ON h.customer_id = s.customer_id
WHERE s.customer_id IS NULL;
GO


/* ============================================================
   TASK 19 — Validate Service Count Against Normalized History
   ============================================================ */

WITH ServiceCounts AS
(
    SELECT
        customer_id,
        COUNT(*) AS calculated_service_count
    FROM analytics.customer_service_history
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS service_count_mismatches
FROM analytics.vehicle_service_features AS f
INNER JOIN ServiceCounts AS s
    ON f.customer_id = s.customer_id
WHERE f.service_count <> s.calculated_service_count;
GO


/* ============================================================
   TASK 20 — Validate Problem-Solution Path
   ============================================================ */

SELECT
    COUNT(*) AS invalid_problem_solution_paths
FROM analytics.vehicle_service_features
WHERE problem_solution_path <>
      CONCAT(problem_category, ' -> ', solution_category);
GO


/* ============================================================
   TASK 21 — Validate STAGING → ANALYTICS Customer Coverage
   ============================================================ */

SELECT
    COUNT(*) AS customers_missing_from_analytics
FROM stg.vehicle_service_clean AS s
LEFT JOIN analytics.vehicle_service_features AS a
    ON s.customer_id = a.customer_id
WHERE a.customer_id IS NULL;
GO


/* ============================================================
   TASK 22 — Diagnose Invalid Analytics Feature Records
   ============================================================ */

SELECT

    SUM(
        CASE
            WHEN customer_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_customer_id,

    SUM(
        CASE
            WHEN problem_category IS NULL
              OR NULLIF(TRIM(problem_category), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_problem_category,

    SUM(
        CASE
            WHEN solution_category IS NULL
              OR NULLIF(TRIM(solution_category), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_solution_category,

    SUM(
        CASE
            WHEN service_count IS NULL
              OR service_count <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_service_count,

    SUM(
        CASE
            WHEN multiple_services_flag IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_multiple_services_flag,

    SUM(
        CASE
            WHEN manufacturer IS NULL
              OR NULLIF(TRIM(manufacturer), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_manufacturer,

    SUM(
        CASE
            WHEN
                customer_id IS NULL
                OR problem_category IS NULL
                OR NULLIF(TRIM(problem_category), '') IS NULL
                OR solution_category IS NULL
                OR NULLIF(TRIM(solution_category), '') IS NULL
                OR service_count IS NULL
                OR service_count <= 0
                OR multiple_services_flag IS NULL
            THEN 1 ELSE 0
        END
    ) AS total_invalid_feature_records

FROM analytics.vehicle_service_features;
GO


/* ============================================================
   TASK 23 — Inspect Unmapped Vehicle Company Values
   ============================================================ */

SELECT
    source_vehicle_company,
    COUNT(*) AS record_count
FROM stg.vehicle_service_clean
WHERE manufacturer IS NULL
GROUP BY source_vehicle_company
ORDER BY record_count DESC,
         source_vehicle_company;
GO


/* ============================================================
   TASK 24 — Validate RAW → STAGING → ANALYTICS Counts
   ============================================================ */

SELECT
    'RAW' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT TRY_CONVERT(INT, TRIM(customer_id_raw)))
        AS distinct_customer_count
FROM raw.vehicle_service

UNION ALL

SELECT
    'STAGING' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id)
        AS distinct_customer_count
FROM stg.vehicle_service_clean

UNION ALL

SELECT
    'ANALYTICS FEATURES' AS data_layer,
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id)
        AS distinct_customer_count
FROM analytics.vehicle_service_features;
GO


/* ============================================================
   TASK 25 — Final Validation Status
   ============================================================ */

DECLARE @ValidationResults TABLE
(
    validation_check VARCHAR(100),
    result INT,
    status VARCHAR(20)
);


/* RAW */

INSERT INTO @ValidationResults
SELECT
    'RAW Row Count',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 508 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM raw.vehicle_service;


INSERT INTO @ValidationResults
SELECT
    'RAW Unique Customers',
    COUNT(DISTINCT TRY_CONVERT(INT, TRIM(customer_id_raw))),
    CASE
        WHEN COUNT(DISTINCT TRY_CONVERT(INT, TRIM(customer_id_raw))) = 500
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM raw.vehicle_service;


/* STAGING */

INSERT INTO @ValidationResults
SELECT
    'STAGING Row Count',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 500 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM stg.vehicle_service_clean;


INSERT INTO @ValidationResults
SELECT
    'STAGING Unique Customers',
    COUNT(DISTINCT customer_id),
    CASE
        WHEN COUNT(DISTINCT customer_id) = 500
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM stg.vehicle_service_clean;


INSERT INTO @ValidationResults
SELECT
    'STAGING NULL Customer IDs',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM stg.vehicle_service_clean
WHERE customer_id IS NULL;


INSERT INTO @ValidationResults
SELECT
    'STAGING Whitespace Issues',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM stg.vehicle_service_clean
WHERE city <> TRIM(city)
   OR state_name <> TRIM(state_name)
   OR common_problem <> TRIM(common_problem)
   OR solution_used <> TRIM(solution_used)
   OR source_vehicle_company <> TRIM(source_vehicle_company);


/* ANALYTICS */

INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Feature Row Count',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 500 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Unique Customers',
    COUNT(DISTINCT customer_id),
    CASE
        WHEN COUNT(DISTINCT customer_id) = 500
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS NULL Customer IDs',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features
WHERE customer_id IS NULL;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Missing Problem Categories',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features
WHERE problem_category IS NULL
   OR NULLIF(TRIM(problem_category), '') IS NULL;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Missing Solution Categories',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features
WHERE solution_category IS NULL
   OR NULLIF(TRIM(solution_category), '') IS NULL;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Invalid Service Counts',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features
WHERE service_count IS NULL
   OR service_count <= 0;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Invalid Multiple-Service Flags',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features
WHERE
    (
        service_count > 1
        AND multiple_services_flag <> 1
    )
    OR
    (
        service_count <= 1
        AND multiple_services_flag <> 0
    );


INSERT INTO @ValidationResults
SELECT
    'STAGING to ANALYTICS Missing Customers',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM stg.vehicle_service_clean AS s
LEFT JOIN analytics.vehicle_service_features AS a
    ON s.customer_id = a.customer_id
WHERE a.customer_id IS NULL;


INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Service Count Mismatches',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.vehicle_service_features AS f
INNER JOIN
(
    SELECT
        customer_id,
        COUNT(*) AS calculated_service_count
    FROM analytics.customer_service_history
    GROUP BY customer_id
) AS h
    ON f.customer_id = h.customer_id
WHERE f.service_count <> h.calculated_service_count;


/* WARNING */

INSERT INTO @ValidationResults
SELECT
    'ANALYTICS Unmapped Manufacturers',
    COUNT(*),
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'WARNING'
    END
FROM analytics.vehicle_service_features
WHERE manufacturer IS NULL
   OR NULLIF(TRIM(manufacturer), '') IS NULL;


/* FINAL RESULT */

SELECT
    validation_check,
    result,
    status
FROM @ValidationResults
ORDER BY
    CASE status
        WHEN 'FAIL' THEN 1
        WHEN 'WARNING' THEN 2
        WHEN 'PASS' THEN 3
    END,
    validation_check;
GO