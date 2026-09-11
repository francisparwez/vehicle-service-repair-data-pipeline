USE VehicleServiceAnalytics;
GO

-- EMPTY TABLE

TRUNCATE TABLE raw.vehicle_service;

-- RUN THE FOLLOWING ONCE

BULK INSERT raw.vehicle_service
FROM 'C:\Users\franc\OneDrive\Desktop\DATA SCIENCE\Vehicle Service Repair Data Pipeline\vehicle-service-repair-data-pipeline\data\vehicle-service_repair.csv'
WITH
(
    DATAFILETYPE = 'char',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- COUNT HOW MANY ROWS ARE CURRENTLY PRESENT

SELECT COUNT(*) AS loaded_rows
FROM raw.vehicle_service;

-- ENTIRE TABLE RESULT

SELECT *
FROM raw.vehicle_service;

