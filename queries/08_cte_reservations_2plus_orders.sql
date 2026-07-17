-- Requirement 8: Reservations that have 2 or more orders, using a CTE.

WITH ReservationsOrders AS (
    SELECT ReservationId, COUNT(OrderId) AS OrdersCount
    FROM Orders
    GROUP BY ReservationId
    HAVING COUNT(OrderId) >= 2
)
SELECT R.ReservationId, RO.OrdersCount, R.ReservationDate, R.PartySize
FROM Reservations AS R
JOIN ReservationsOrders AS RO ON R.ReservationId = RO.ReservationId
ORDER BY RO.OrdersCount DESC, R.ReservationId;
