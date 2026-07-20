-- Requirement 1: List all reservations for a specific customer.
-- @CustomerId is supplied by the caller. To run this file on its own, prepend:
--     DECLARE @CustomerId INT = 34;

SELECT r.ReservationId, r.RestaurantId, r.TableId, r.ReservationDate, r.PartySize
FROM Reservations AS r
WHERE r.CustomerId = @CustomerId
ORDER BY r.ReservationDate DESC;