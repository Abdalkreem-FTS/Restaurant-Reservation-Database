-- Requirement 11: Function returning the total revenue for a restaurant.

CREATE OR ALTER FUNCTION dbo.fn_CalculateRevenue (@RestaurantId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2);

    SELECT @Result = SUM(o.TotalAmount)
    FROM Reservations AS r JOIN Orders AS o ON r.ReservationId = o.ReservationId
    WHERE r.RestaurantId = @RestaurantId;

    RETURN ISNULL(@Result, 0);
END
GO

SELECT 1 AS RestaurantId, dbo.fn_CalculateRevenue(1) AS TotalRevenue
UNION ALL
SELECT 2, dbo.fn_CalculateRevenue(2);
