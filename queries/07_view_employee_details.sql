-- 07_view_employee_details.sql
CREATE OR REPLACE VIEW EmployeesDetails AS
SELECT e.EmployeeId, e.FirstName, e.LastName,
       e.FirstName || ' ' || e.LastName AS EmployeeName,
       e.Position,
       r.RestaurantId,
       r.Name        AS RestaurantName,
       r.Address     AS RestaurantAddress,
       r.PhoneNumber AS RestaurantPhone,
       r.OpeningHours
FROM Employees   AS e
         JOIN Restaurants AS r ON e.RestaurantId = r.RestaurantId;

SELECT * FROM EmployeesDetails ORDER BY RestaurantId, EmployeeId;