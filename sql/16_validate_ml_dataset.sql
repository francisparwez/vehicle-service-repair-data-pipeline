USE VehicleServiceAnalytics;
GO

/* ============================================================
   TASK 5 — Validate ML Dataset
   ============================================================ */

SELECT
    COUNT(*) AS ml_row_count,
    COUNT(DISTINCT customer_id) AS ml_unique_customers
FROM ml.vehicle_service_features;
GO

SELECT
    COUNT(*) AS duplicate_customer_records
FROM
(
    SELECT
        customer_id
    FROM ml.vehicle_service_features
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS duplicates;
GO

SELECT
    COUNT(*) AS missing_from_analytics
FROM analytics.vehicle_service_features AS a
LEFT JOIN ml.vehicle_service_features AS m
    ON a.customer_id = m.customer_id
WHERE m.customer_id IS NULL;
GO

SELECT
    COUNT(*) AS missing_from_staging
FROM stg.vehicle_service_clean AS s
LEFT JOIN ml.vehicle_service_features AS m
    ON s.customer_id = m.customer_id
WHERE m.customer_id IS NULL;
GO

SELECT
    COUNT(*) AS ml_records_not_in_analytics
FROM ml.vehicle_service_features AS m
LEFT JOIN analytics.vehicle_service_features AS a
    ON m.customer_id = a.customer_id
WHERE a.customer_id IS NULL;
GO