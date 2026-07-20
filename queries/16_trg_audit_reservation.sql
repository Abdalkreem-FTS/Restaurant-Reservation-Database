-- Requirement 16: Log an entry into the AuditLog table whenever a table gets reserved (a row is inserted into Reservations).
-- The AuditLog table itself is created in 01_create_tables.sql.

CREATE OR ALTER TRIGGER trg_AuditReservation
ON Reservations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (RestaurantId, TableId, ReservationDate, ChangeDate)
    SELECT i.RestaurantId, i.TableId, i.ReservationDate, GETDATE()
    FROM inserted AS i;
END
