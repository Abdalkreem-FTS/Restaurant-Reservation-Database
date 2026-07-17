USE master;
GO

IF DB_ID('RestaurantReservationDB') IS NOT NULL
BEGIN
    ALTER DATABASE RestaurantReservationDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RestaurantReservationDB;
END
GO

CREATE DATABASE RestaurantReservationDB;
GO

USE RestaurantReservationDB;
GO
