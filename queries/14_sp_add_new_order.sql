-- Requirement 14: Add a new order.

CREATE OR ALTER PROCEDURE dbo.sp_AddNewOrder
    @ReservationId INT,
    @EmployeeId INT,
    @OrderDate DATETIME,
    @TotalAmount DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Reservations WHERE ReservationId = @ReservationId)
    BEGIN
        RAISERROR('Reservation %d does not exist.', 16, 1, @ReservationId);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
    BEGIN
        RAISERROR('Employee %d does not exist.', 16, 1, @EmployeeId);
        RETURN;
    END;

    INSERT INTO Orders (ReservationId, EmployeeId, OrderDate, TotalAmount)
    VALUES (@ReservationId, @EmployeeId, @OrderDate, @TotalAmount);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewOrderId;
END
GO

EXEC dbo.sp_AddNewOrder @ReservationId = 1, @EmployeeId = 1, @OrderDate = '2026-07-15', @TotalAmount = 42.50;
EXEC dbo.sp_AddNewOrder @ReservationId = 999999, @EmployeeId = 1, @OrderDate = '2026-07-15', @TotalAmount = 42.50;
