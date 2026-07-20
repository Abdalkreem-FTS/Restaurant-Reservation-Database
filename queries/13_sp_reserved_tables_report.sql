-- Requirement 13: Report of tables reserved within a date range, with reservation date, party size and restaurant details.

CREATE OR ALTER PROCEDURE dbo.sp_ReservedTablesReport
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.TableId, rt.RestaurantId, rt.[Name] AS RestaurantName, res.ReservationDate,
           res.PartySize, t.Capacity, rt.[Address], rt.PhoneNumber, rt.OpeningHours
    FROM Reservations AS res
    JOIN [Tables] AS t ON res.TableId = t.TableId
    JOIN Restaurants AS rt ON res.RestaurantId = rt.RestaurantId
    WHERE res.ReservationDate BETWEEN @StartDate AND @EndDate
    ORDER BY res.ReservationDate, rt.RestaurantId, t.TableId;
END