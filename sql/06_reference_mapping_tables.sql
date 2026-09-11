-- 01 Inconsistencies With Names Can Be Improved By Mapping
DROP TABLE IF EXISTS stg.vehicle_company_mapping;
GO

CREATE TABLE stg.vehicle_company_mapping
(
    source_value          VARCHAR(255) PRIMARY KEY,
    manufacturer_standard VARCHAR(100),
    model_standard        VARCHAR(100),
    vehicle_type          VARCHAR(50)
);

INSERT INTO stg.vehicle_company_mapping
(
    source_value,
    manufacturer_standard,
    model_standard,
    vehicle_type
)
VALUES

('Ford', 'Ford', NULL, NULL),
('Ford EcoSport', 'Ford', 'EcoSport', 'Car'),
('Ford Figo', 'Ford', 'Figo', 'Car'),

('Hyundai', 'Hyundai', NULL, NULL),
('Hyundai Creta', 'Hyundai', 'Creta', 'Car'),
('Hyundai Verna', 'Hyundai', 'Verna', 'Car'),

('Hero MotoCorp', 'Hero MotoCorp', NULL, 'Motorcycle'),
('Hero Motocrop', 'Hero MotoCorp', NULL, 'Motorcycle'),

('Mahindra', 'Mahindra & Mahindra', NULL, NULL),
('Mahindra & Mahindra', 'Mahindra & Mahindra', NULL, NULL);