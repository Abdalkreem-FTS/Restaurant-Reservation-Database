-- Requirement 6: A view listing every reservation together with its restaurant and customer details.

CREATE OR ALTER VIEW ReservationsReport AS
SELECT res.ReservationId,
       res.ReservationDate,
       res.PartySize,
       res.TableId,
       r.RestaurantId,
       r.[Name] AS RestaurantName,
       r.[Address] AS RestaurantAddress,
       r.PhoneNumber AS RestaurantPhone,
       r.OpeningHours,
       c.CustomerId,
       c.FirstName AS CustomerFirstName,
       c.LastName AS CustomerLastName,
       c.Email AS CustomerEmail,
       c.PhoneNumber AS CustomerPhone
FROM Reservations AS res
JOIN Restaurants AS r ON res.RestaurantId = r.RestaurantId
JOIN Customers AS c ON res.CustomerId   = c.CustomerId;
