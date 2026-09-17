USE VehicleServiceAnalytics;
GO

/* ============================================================
   PHASE 8 - FEATURE ENGINEERING
   ============================================================

   Purpose:
   Create analytical features from the cleaned and normalized
   vehicle service data.

   Source tables:
       stg.vehicle_service_clean
       analytics.customer_service_history

   Reference table:
       stg.solution_mapping

   Output:
       analytics.vehicle_service_features

   Grain:
       One row per customer

   Features:
       1. Number of Services
       2. Multi-Service Indicator
       3. Problem Category
       4. Solution Category
       5. Manufacturer
       6. Model Available Flag
       7. Problem/Solution Combination
   ============================================================ */


-- ============================================================
-- 1. Create Solution Mapping Table
-- ============================================================

DROP TABLE IF EXISTS stg.solution_mapping;
GO

CREATE TABLE stg.solution_mapping
(
    source_value      VARCHAR(255) NOT NULL,
    solution_category VARCHAR(100) NOT NULL,

    CONSTRAINT PK_solution_mapping
        PRIMARY KEY (source_value)
);
GO


-- ============================================================
-- 2. Populate Solution Mapping Table
-- ============================================================

/*
    Build a reference mapping from the actual solution values
    found in the cleaned staging table.

    The mapping converts detailed solution descriptions into
    broader analytical categories.
*/

INSERT INTO stg.solution_mapping
(
    source_value,
    solution_category
)
SELECT DISTINCT
    solution_used AS source_value,

    CASE
        WHEN LOWER(solution_used) LIKE '%repair%'
            THEN 'Repair'

        WHEN LOWER(solution_used) LIKE '%replace%'
            THEN 'Replacement'

        WHEN LOWER(solution_used) LIKE '%adjust%'
            THEN 'Adjustment'

        WHEN LOWER(solution_used) LIKE '%clean%'
            THEN 'Cleaning'

        WHEN LOWER(solution_used) LIKE '%diagnos%'
            THEN 'Diagnostic'

        WHEN LOWER(solution_used) LIKE '%maintain%'
            THEN 'Maintenance'

        ELSE 'Other'
    END AS solution_category

FROM stg.vehicle_service_clean
WHERE solution_used IS NOT NULL;
GO


-- ============================================================
-- 3. Validate Solution Mapping Coverage
-- ============================================================

/*
    Identify solution values that do not have a mapping.

    Expected result:
        0 rows
*/

SELECT DISTINCT
    v.solution_used
FROM stg.vehicle_service_clean AS v
LEFT JOIN stg.solution_mapping AS m
    ON v.solution_used = m.source_value
WHERE v.solution_used IS NOT NULL
  AND m.source_value IS NULL;
GO


-- ============================================================
-- 4. Review Solution Mapping
-- ============================================================

SELECT
    source_value,
    solution_category
FROM stg.solution_mapping
ORDER BY
    solution_category,
    source_value;
GO


-- ============================================================
-- 5. Recreate Feature Table
-- ============================================================

DROP TABLE IF EXISTS analytics.vehicle_service_features;
GO

CREATE TABLE analytics.vehicle_service_features
(
    customer_id INT NOT NULL,

    -- Service Features
    service_count INT NOT NULL,
    multiple_services_flag BIT NOT NULL,

    -- Problem Features
    problem_category VARCHAR(100) NOT NULL,

    -- Solution Features
    solution_category VARCHAR(100) NOT NULL,

    -- Vehicle Features
    manufacturer VARCHAR(100) NULL,
    vehicle_model VARCHAR(100) NULL,
    model_known_flag BIT NOT NULL,

    -- Combined Analytical Feature
    problem_solution_path VARCHAR(255) NOT NULL,

    -- Metadata
    feature_created_at DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT PK_vehicle_service_features
        PRIMARY KEY (customer_id)
);
GO


-- ============================================================
-- 6. Build Features
-- ============================================================

WITH ServiceFeatures AS
(
    /* --------------------------------------------------------
       Feature 1 - Number of Services
       Feature 2 - Multi-Service Indicator
       -------------------------------------------------------- */

    SELECT
        customer_id,

        COUNT(*) AS service_count,

        CASE
            WHEN COUNT(*) > 1 THEN 1
            ELSE 0
        END AS multiple_services_flag

    FROM analytics.customer_service_history

    GROUP BY
        customer_id
),

BaseData AS
(
    SELECT
        v.customer_id,
        v.common_problem,
        v.solution_used,
        v.manufacturer,
        v.vehicle_model,

        -- Feature 4 source
        m.solution_category,

        -- Feature 1
        COALESCE(
            sf.service_count,
            0
        ) AS service_count,

        -- Feature 2
        COALESCE(
            sf.multiple_services_flag,
            0
        ) AS multiple_services_flag

    FROM stg.vehicle_service_clean AS v

    LEFT JOIN ServiceFeatures AS sf
        ON v.customer_id = sf.customer_id

    LEFT JOIN stg.solution_mapping AS m
        ON v.solution_used = m.source_value
),

CategorisedData AS
(
    SELECT
        customer_id,

        service_count,

        multiple_services_flag,


        -- ====================================================
        -- Feature 3 - Problem Category
        -- ====================================================

        CASE
            WHEN LOWER(common_problem) LIKE '%brake%'
                THEN 'Braking'

            WHEN LOWER(common_problem) LIKE '%engine%'
                THEN 'Engine'

            WHEN LOWER(common_problem) LIKE '%tire%'
              OR LOWER(common_problem) LIKE '%wheel%'
                THEN 'Tires & Wheels'

            WHEN LOWER(common_problem) LIKE '%headlight%'
                THEN 'Lighting'

            WHEN LOWER(common_problem) LIKE '%battery%'
                THEN 'Electrical'

            WHEN LOWER(common_problem) LIKE '%transmission%'
                THEN 'Transmission'

            WHEN LOWER(common_problem) LIKE '%exhaust%'
                THEN 'Exhaust'

            WHEN LOWER(common_problem) LIKE '%steering%'
                THEN 'Steering'

            ELSE 'Other'
        END AS problem_category,


        -- ====================================================
        -- Feature 4 - Solution Category
        -- Mapping-table driven
        -- ====================================================

        COALESCE(
            solution_category,
            'Other'
        ) AS solution_category,


        -- ====================================================
        -- Feature 5 - Manufacturer
        -- ====================================================

        manufacturer,


        -- ====================================================
        -- Vehicle Model
        -- ====================================================

        vehicle_model,


        -- ====================================================
        -- Feature 6 - Model Available Flag
        -- ====================================================

        CASE
            WHEN vehicle_model IS NOT NULL
             AND TRIM(vehicle_model) <> ''
                THEN 1

            ELSE 0
        END AS model_known_flag

    FROM BaseData
)


-- ============================================================
-- 7. Insert Feature Dataset
-- ============================================================

INSERT INTO analytics.vehicle_service_features
(
    customer_id,
    service_count,
    multiple_services_flag,
    problem_category,
    solution_category,
    manufacturer,
    vehicle_model,
    model_known_flag,
    problem_solution_path
)

SELECT
    customer_id,

    -- Feature 1
    service_count,

    -- Feature 2
    multiple_services_flag,

    -- Feature 3
    problem_category,

    -- Feature 4
    solution_category,

    -- Feature 5
    manufacturer,

    vehicle_model,

    -- Feature 6
    model_known_flag,


    -- ========================================================
    -- Feature 7 - Problem/Solution Combination
    -- ========================================================

    CONCAT(
        problem_category,
        ' -> ',
        solution_category
    ) AS problem_solution_path

FROM CategorisedData;
GO


-- ============================================================
-- 8. Feature Engineering Validation
-- ============================================================


-- ------------------------------------------------------------
-- 8.1 Check Total Feature Rows
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS feature_rows
FROM analytics.vehicle_service_features;
GO


-- ------------------------------------------------------------
-- 8.2 Check Feature Table
-- ------------------------------------------------------------

SELECT *
FROM analytics.vehicle_service_features;
GO


-- ------------------------------------------------------------
-- 8.3 Validate Customer Uniqueness
-- ------------------------------------------------------------

SELECT
    customer_id,
    COUNT(*) AS row_count
FROM analytics.vehicle_service_features
GROUP BY
    customer_id
HAVING COUNT(*) > 1;
GO


-- ------------------------------------------------------------
-- 8.4 Validate Service Features
-- ------------------------------------------------------------

SELECT
    multiple_services_flag,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    multiple_services_flag
ORDER BY
    multiple_services_flag;
GO


-- ------------------------------------------------------------
-- 8.5 Validate Service Count
-- ------------------------------------------------------------

SELECT
    MIN(service_count) AS minimum_service_count,
    MAX(service_count) AS maximum_service_count,
    AVG(
        CAST(service_count AS DECIMAL(10,2))
    ) AS average_service_count
FROM analytics.vehicle_service_features;
GO


-- ------------------------------------------------------------
-- 8.6 Validate Problem Categories
-- ------------------------------------------------------------

SELECT
    problem_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    problem_category
ORDER BY
    customer_count DESC;
GO


-- ------------------------------------------------------------
-- 8.7 Validate Solution Categories
-- ------------------------------------------------------------

SELECT
    solution_category,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    solution_category
ORDER BY
    customer_count DESC;
GO


-- ------------------------------------------------------------
-- 8.8 Validate Problem/Solution Paths
-- ------------------------------------------------------------

SELECT
    problem_solution_path,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    problem_solution_path
ORDER BY
    customer_count DESC;
GO


-- ------------------------------------------------------------
-- 8.9 Validate Manufacturer / Model Features
-- ------------------------------------------------------------

SELECT
    manufacturer,
    model_known_flag,
    COUNT(*) AS customer_count
FROM analytics.vehicle_service_features
GROUP BY
    manufacturer,
    model_known_flag
ORDER BY
    manufacturer,
    model_known_flag;
GO


-- ------------------------------------------------------------
-- 8.10 Validate Missing Feature Values
-- ------------------------------------------------------------

SELECT
    SUM(
        CASE
            WHEN problem_category IS NULL
                THEN 1
            ELSE 0
        END
    ) AS missing_problem_category,

    SUM(
        CASE
            WHEN solution_category IS NULL
                THEN 1
            ELSE 0
        END
    ) AS missing_solution_category,

    SUM(
        CASE
            WHEN problem_solution_path IS NULL
                THEN 1
            ELSE 0
        END
    ) AS missing_problem_solution_path
FROM analytics.vehicle_service_features;
GO


-- ------------------------------------------------------------
-- 8.11 Feature Summary
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_customers,

    AVG(
        CAST(service_count AS DECIMAL(10,2))
    ) AS average_service_count,

    SUM(
        CASE
            WHEN multiple_services_flag = 1
                THEN 1
            ELSE 0
        END
    ) AS customers_with_multiple_services,

    SUM(
        CASE
            WHEN model_known_flag = 1
                THEN 1
            ELSE 0
        END
    ) AS customers_with_known_model

FROM analytics.vehicle_service_features;
GO