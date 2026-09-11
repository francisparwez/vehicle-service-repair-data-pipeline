DROP TABLE IF EXISTS stg.vehicle_service_clean;
GO

CREATE TABLE stg.vehicle_service_clean
(
    customer_id INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    service_history VARCHAR(1000) NULL,
    common_problem VARCHAR(255) NULL,
    solution_used VARCHAR(255) NULL,
    manufacturer VARCHAR(100) NULL,
    vehicle_model VARCHAR(100) NULL,
    vehicle_type VARCHAR(50) NULL,
    source_vehicle_company VARCHAR(255) NULL,
    processed_at DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),
    CONSTRAINT PK_vehicle_service_clean
        PRIMARY KEY (customer_id)
);

WITH Deduplicated AS
(
    SELECT
        *,
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
            ORDER BY (SELECT NULL)
        ) AS duplicate_rank

    FROM raw.vehicle_service
)

INSERT INTO stg.vehicle_service_clean
(
    customer_id,
    city,
    state_name,
    service_history,
    common_problem,
    solution_used,
    manufacturer,
    vehicle_model,
    vehicle_type,
    source_vehicle_company
)

SELECT
    TRY_CONVERT(INT, TRIM(d.customer_id_raw)),
    TRIM(d.city_raw),
    TRIM(d.state_raw),
    TRIM(d.service_history_raw),
    TRIM(d.common_problem_raw),
    TRIM(d.solution_used_raw),
    m.manufacturer_standard,
    m.model_standard,
    m.vehicle_type,
    TRIM(d.vehicle_company_raw)
FROM Deduplicated AS d

LEFT JOIN stg.vehicle_company_mapping AS m
    ON TRIM(d.vehicle_company_raw) = m.source_value

WHERE d.duplicate_rank = 1;