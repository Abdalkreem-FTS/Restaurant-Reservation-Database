-- 05_avg_order_amount_by_employee.sql

SELECT 50 AS EmployeeId, COUNT(*) AS OrdersCount, AVG(TotalAmount) AS AverageOrderAmount
FROM Orders
WHERE EmployeeId = 50;