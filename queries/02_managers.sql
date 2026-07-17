-- 02_managers.sql

SELECT EmployeeId, RestaurantId, FirstName, LastName, Position
FROM Employees
WHERE Position = 'Manager'
ORDER BY RestaurantId, EmployeeId;