-- 01_customer_reservations.sql

SELECT r.ReservationId, r.RestaurantId, r.TableId, r.ReservationDate, r.PartySize
FROM Reservations AS r
WHERE r.CustomerId = 1
ORDER BY r.ReservationDate;