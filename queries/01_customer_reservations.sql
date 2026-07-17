-- Requirement 1: List all reservations for a specific customer.

DECLARE @CustomerId INT = 1;

SELECT r.ReservationId, r.RestaurantId, r.TableId, r.ReservationDate, r.PartySize
FROM Reservations AS r
WHERE r.CustomerId = @CustomerId
ORDER BY r.ReservationDate;