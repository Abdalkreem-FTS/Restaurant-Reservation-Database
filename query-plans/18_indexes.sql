-- Requirement 18: Indexes.

-- Reservations
DROP INDEX IF EXISTS IX_Reservations_CustomerId;
DROP INDEX IF EXISTS IX_Reservations_RestaurantId;
DROP INDEX IF EXISTS IX_Reservations_TableId;
DROP INDEX IF EXISTS IX_Reservations_ReservationDate;

CREATE INDEX IX_Reservations_CustomerId       ON Reservations(CustomerId);
CREATE INDEX IX_Reservations_RestaurantId     ON Reservations(RestaurantId);
CREATE INDEX IX_Reservations_TableId          ON Reservations(TableId);
CREATE INDEX IX_Reservations_ReservationDate  ON Reservations(ReservationDate)
    INCLUDE (RestaurantId, TableId, PartySize);

-- Orders
DROP INDEX IF EXISTS IX_Orders_ReservationId;
DROP INDEX IF EXISTS IX_Orders_EmployeeId;
DROP INDEX IF EXISTS IX_Orders_OrderDate;

CREATE INDEX IX_Orders_ReservationId ON Orders(ReservationId)
    INCLUDE (EmployeeId, OrderDate, TotalAmount);
CREATE INDEX IX_Orders_EmployeeId    ON Orders(EmployeeId) INCLUDE (TotalAmount);
CREATE INDEX IX_Orders_OrderDate     ON Orders(OrderDate)  INCLUDE (ReservationId);

-- OrderItems
DROP INDEX IF EXISTS IX_OrderItems_OrderId;
DROP INDEX IF EXISTS IX_OrderItems_ItemId;

CREATE INDEX IX_OrderItems_OrderId ON OrderItems(OrderId) INCLUDE (ItemId, Quantity);
CREATE INDEX IX_OrderItems_ItemId  ON OrderItems(ItemId)  INCLUDE (Quantity);

-- MenuItems / Employees / Tables (foreign keys)
DROP INDEX IF EXISTS IX_MenuItems_RestaurantId;
DROP INDEX IF EXISTS IX_Employees_RestaurantId;
DROP INDEX IF EXISTS IX_Tables_RestaurantId;

CREATE INDEX IX_MenuItems_RestaurantId ON MenuItems(RestaurantId);
CREATE INDEX IX_Employees_RestaurantId ON Employees(RestaurantId);
CREATE INDEX IX_Tables_RestaurantId    ON Tables(RestaurantId);

-- Refresh planner statistics so the new indexes are actually considered.
ANALYZE;