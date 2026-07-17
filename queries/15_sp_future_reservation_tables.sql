-- Requirement 15: Retrieve all tables that have future reservations into a temporary table, then join it with Restaurants to list the restaurant details.

CREATE OR ALTER PROCEDURE dbo.sp_FutureReservationTables
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#FutureTables') IS NOT NULL
        DROP TABLE #FutureTables;

    SELECT DISTINCT R.TableId, R.RestaurantId
    INTO #FutureTables
    FROM Reservations AS R
    WHERE R.ReservationDate > GETDATE();

    SELECT FT.TableId, RT.RestaurantId, RT.[Name] AS RestaurantName, RT.[Address], RT.PhoneNumber, RT.OpeningHours
    FROM #FutureTables AS FT JOIN Restaurants AS RT ON RT.RestaurantId = FT.RestaurantId
    ORDER BY RT.RestaurantId, FT.TableId;

    DROP TABLE #FutureTables;
END
GO

EXEC dbo.sp_FutureReservationTables;
