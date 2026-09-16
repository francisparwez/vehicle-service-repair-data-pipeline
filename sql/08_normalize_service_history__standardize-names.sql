CREATE TABLE analytics.customer_service_history
(
    customer_id INT NOT NULL,
    service_name VARCHAR(255) NOT NULL
);

INSERT INTO analytics.customer_service_history
(
    customer_id,
    [service_name]
)

SELECT
    v.customer_id,
    TRIM(s.value)

FROM stg.vehicle_service_clean AS v

CROSS APPLY STRING_SPLIT(v.service_history, ';') AS s

WHERE TRIM(s.value) <> '';