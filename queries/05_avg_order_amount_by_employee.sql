-- Requirement 5: Average order amount handled by a specific employee.
-- @EmployeeId is supplied by the caller. To run this file on its own, prepend:
--     DECLARE @EmployeeId INT = 50;

SELECT @EmployeeId AS EmployeeId, COUNT(*) AS OrdersCount, AVG(TotalAmount) AS AverageOrderAmount
FROM Orders
WHERE EmployeeId = @EmployeeId;
