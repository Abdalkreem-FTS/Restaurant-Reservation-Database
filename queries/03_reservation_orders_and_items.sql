-- Requirement 3: Orders placed on a given reservation, with their menu items.

DECLARE @ReservationId INT = 7;

SELECT O.OrderId, O.EmployeeId, O.OrderDate, MI.ItemId, MI.[Name] AS ItemName, MI.Price, OI.Quantity, O.TotalAmount
FROM Orders AS O
JOIN OrderItems AS OI ON O.OrderId = OI.OrderId
JOIN MenuItems AS MI ON OI.ItemId = MI.ItemId
WHERE O.ReservationId = @ReservationId
ORDER BY O.OrderId, MI.ItemId;
