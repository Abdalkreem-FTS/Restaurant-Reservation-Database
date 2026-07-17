-- 08_cte_reservations_2plus_orders.sql   (unchanged - standard SQL)
WITH ReservationsOrders AS (
    SELECT ReservationId, COUNT(OrderId) AS OrdersCount
    FROM Orders
    GROUP BY ReservationId
    HAVING COUNT(OrderId) >= 2
)
SELECT r.ReservationId, ro.OrdersCount, r.ReservationDate, r.PartySize
FROM Reservations       AS r
         JOIN ReservationsOrders AS ro ON r.ReservationId = ro.ReservationId
ORDER BY ro.OrdersCount DESC, r.ReservationId;