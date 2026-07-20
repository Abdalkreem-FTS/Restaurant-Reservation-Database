-- Requirement 10: Most popular menu item for each restaurant in a given month.
-- @Year and @Month are supplied by the caller. To run this file on its own, prepend:
--     DECLARE @Year INT = 2025, @Month INT = 11;

WITH ItemPopularity AS (
    SELECT r.RestaurantId, oi.ItemId, SUM(oi.Quantity) AS UnitsSold,
           ROW_NUMBER() OVER (PARTITION BY r.RestaurantId ORDER BY SUM(oi.Quantity) DESC, oi.ItemId) AS PopularityRank
    FROM Reservations AS r
    JOIN Orders AS o ON r.ReservationId = o.ReservationId
    JOIN OrderItems AS oi ON o.OrderId = oi.OrderId
    WHERE YEAR(o.OrderDate) = @Year AND MONTH(o.OrderDate) = @Month
    GROUP BY r.RestaurantId, oi.ItemId
)
SELECT p.RestaurantId, p.ItemId, m.[Name] AS ItemName, p.UnitsSold
FROM ItemPopularity AS p JOIN MenuItems AS m ON m.ItemId = p.ItemId
WHERE p.PopularityRank = 1
ORDER BY p.RestaurantId;
