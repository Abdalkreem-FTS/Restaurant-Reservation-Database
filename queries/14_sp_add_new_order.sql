-- 14_sp_add_new_order.sql
-- RAISERROR -> RAISE EXCEPTION ; SCOPE_IDENTITY() -> RETURNING ... INTO
CREATE OR REPLACE FUNCTION sp_AddNewOrder(
    p_reservation_id INT,
    p_employee_id    INT,
    p_order_date     TIMESTAMP,
    p_total_amount   NUMERIC(10,2)
)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_new_order_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Reservations WHERE ReservationId = p_reservation_id) THEN
        RAISE EXCEPTION 'Reservation % does not exist.', p_reservation_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = p_employee_id) THEN
        RAISE EXCEPTION 'Employee % does not exist.', p_employee_id;
    END IF;

    INSERT INTO Orders (ReservationId, EmployeeId, OrderDate, TotalAmount)
    VALUES (p_reservation_id, p_employee_id, p_order_date, p_total_amount)
    RETURNING OrderId INTO v_new_order_id;

    RETURN v_new_order_id;
END;
$$;

SELECT sp_AddNewOrder(1, 1, '2026-07-15', 42.50) AS NewOrderId;
SELECT sp_AddNewOrder(999999, 1, '2026-07-15', 42.50);   -- raises the error