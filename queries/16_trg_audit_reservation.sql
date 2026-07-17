-- Requirement 16: Log an entry into an AuditLog table whenever a table gets reserved (a row is inserted into Reservations).

IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE AuditLog (
        AuditId INT IDENTITY(1,1) PRIMARY KEY,
        RestaurantId INT,
        TableId INT,
        ReservationDate DATETIME,
        ChangeDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

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
GO

BEGIN TRANSACTION;
    INSERT INTO Reservations (CustomerId, RestaurantId, TableId, ReservationDate, PartySize)
    VALUES (1, 1, 1, DATEADD(DAY, 30, GETDATE()), 2);

    SELECT TOP 5 * FROM AuditLog ORDER BY AuditId DESC;
ROLLBACK;
