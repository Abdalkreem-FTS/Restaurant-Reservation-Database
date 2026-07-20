-- Requirement 7: A view listing every employee together with their restaurant details.

CREATE OR ALTER VIEW EmployeesDetails AS
SELECT e.EmployeeId,
       e.FirstName,
       e.LastName,
       CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
       e.Position,
       r.RestaurantId,
       r.[Name] AS RestaurantName,
       r.[Address] AS RestaurantAddress,
       r.PhoneNumber AS RestaurantPhone,
       r.OpeningHours
FROM Employees AS e
JOIN Restaurants AS r ON e.RestaurantId = r.RestaurantId;
