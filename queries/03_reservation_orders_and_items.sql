-- 03_reservation_orders_and_items.sql

SELECT o.OrderId, o.EmployeeId, o.OrderDate, mi.ItemId, mi.Name AS ItemName,
       mi.Price, oi.Quantity, o.TotalAmount
FROM Orders AS o
         JOIN OrderItems AS oi ON o.OrderId = oi.OrderId
         JOIN MenuItems  AS mi ON oi.ItemId = mi.ItemId
WHERE o.ReservationId = 7
ORDER BY o.OrderId, mi.ItemId;