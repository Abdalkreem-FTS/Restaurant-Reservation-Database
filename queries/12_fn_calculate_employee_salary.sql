-- Requirement 12: Function returning an employee's salary.

CREATE OR ALTER FUNCTION dbo.fn_CalculateEmployeeSalary (@EmployeeId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Rank INT, @OrdersCount INT;

    SELECT @Rank = CASE Position
                        WHEN 'VIPOrdersWaiter' THEN 5
                        WHEN 'StandardWaiter'  THEN 4
                        WHEN 'AssistantWaiter' THEN 3
                        ELSE 0
                   END
    FROM Employees
    WHERE EmployeeId = @EmployeeId;

    SELECT @OrdersCount = COUNT(*)
    FROM Orders
    WHERE EmployeeId = @EmployeeId;

    RETURN ISNULL(@OrdersCount, 0) * ISNULL(@Rank, 0);
END
GO

SELECT e.EmployeeId, e.Position, dbo.fn_CalculateEmployeeSalary(e.EmployeeId) AS Salary
FROM Employees AS e
WHERE e.EmployeeId IN (1, 50, 60, 100)
ORDER BY e.EmployeeId;
