-- 12_fn_calculate_employee_salary.sql
CREATE OR REPLACE FUNCTION fn_CalculateEmployeeSalary(p_employee_id INT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_rank   INT;
    v_orders INT;
BEGIN
    SELECT CASE e.Position
               WHEN 'VIPOrdersWaiter' THEN 5
               WHEN 'StandardWaiter'  THEN 4
               WHEN 'AssistantWaiter' THEN 3
               ELSE 0
               END
    INTO v_rank
    FROM Employees AS e
    WHERE e.EmployeeId = p_employee_id;

    SELECT COUNT(*) INTO v_orders
    FROM Orders AS o
    WHERE o.EmployeeId = p_employee_id;

    RETURN COALESCE(v_orders, 0) * COALESCE(v_rank, 0);
END;
$$;

SELECT e.EmployeeId, e.Position, fn_CalculateEmployeeSalary(e.EmployeeId) AS Salary
FROM Employees AS e
WHERE e.EmployeeId IN (1, 50, 60, 100)
ORDER BY e.EmployeeId;