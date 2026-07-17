-- Requirement 2: List all employees who hold the 'Manager' position.

SELECT EmployeeId, RestaurantId, FirstName, LastName, Position
FROM Employees
WHERE Position = 'Manager'
ORDER BY RestaurantId, EmployeeId;
