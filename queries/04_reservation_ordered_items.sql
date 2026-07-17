-- 04_reservation_ordered_items.sql

SELECT DISTINCT mi.ItemId, mi.RestaurantId, mi.Name, mi.Description, mi.Price
FROM Orders AS o
         JOIN OrderItems AS oi ON o.OrderId = oi.OrderId
         JOIN MenuItems  AS mi ON oi.ItemId = mi.ItemId
WHERE o.ReservationId = 7
ORDER BY mi.ItemId;