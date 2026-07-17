-- Requirement 4: Distinct menu items ordered by a given reservation.

DECLARE @ReservationId INT = 7;

SELECT DISTINCT MI.ItemId, MI.RestaurantId, MI.[Name], MI.[Description], MI.Price
FROM Orders AS O
JOIN OrderItems AS OI ON O.OrderId = OI.OrderId
JOIN MenuItems AS MI ON OI.ItemId = MI.ItemId
WHERE O.ReservationId = @ReservationId
ORDER BY MI.ItemId;
