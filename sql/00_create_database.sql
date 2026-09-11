USE master;
GO

IF DB_ID('VehicleServiceAnalytics') IS NULL
BEGIN
    CREATE DATABASE VehicleServiceAnalytics;
END;
GO

USE VehicleServiceAnalytics;
GO