-- Requirement 18: Indexes.

-- Reservations
DROP INDEX IF EXISTS IX_Reservations_CustomerId ON Reservations;
DROP INDEX IF EXISTS IX_Reservations_RestaurantId ON Reservations;
DROP INDEX IF EXISTS IX_Reservations_TableId ON Reservations;
DROP INDEX IF EXISTS IX_Reservations_ReservationDate ON Reservations;

CREATE NONCLUSTERED INDEX IX_Reservations_CustomerId ON Reservations(CustomerId);
CREATE NONCLUSTERED INDEX IX_Reservations_RestaurantId ON Reservations(RestaurantId);
CREATE NONCLUSTERED INDEX IX_Reservations_TableId ON Reservations(TableId);
CREATE NONCLUSTERED INDEX IX_Reservations_ReservationDate ON Reservations(ReservationDate) INCLUDE (RestaurantId, TableId, PartySize);

-- Orders
DROP INDEX IF EXISTS IX_Orders_ReservationId ON Orders;
DROP INDEX IF EXISTS IX_Orders_EmployeeId ON Orders;
DROP INDEX IF EXISTS IX_Orders_OrderDate ON Orders;

CREATE NONCLUSTERED INDEX IX_Orders_ReservationId ON Orders(ReservationId) INCLUDE (EmployeeId, OrderDate, TotalAmount);
CREATE NONCLUSTERED INDEX IX_Orders_EmployeeId ON Orders(EmployeeId) INCLUDE (TotalAmount);
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON Orders(OrderDate) INCLUDE (ReservationId);

-- OrderItems
DROP INDEX IF EXISTS IX_OrderItems_OrderId ON OrderItems;
DROP INDEX IF EXISTS IX_OrderItems_ItemId ON OrderItems;

CREATE NONCLUSTERED INDEX IX_OrderItems_OrderId ON OrderItems(OrderId) INCLUDE (ItemId, Quantity);
CREATE NONCLUSTERED INDEX IX_OrderItems_ItemId ON OrderItems(ItemId) INCLUDE (Quantity);

-- MenuItems / Employees / Tables
DROP INDEX IF EXISTS IX_MenuItems_RestaurantId ON MenuItems;
DROP INDEX IF EXISTS IX_Employees_RestaurantId ON Employees;
DROP INDEX IF EXISTS IX_Tables_RestaurantId    ON [Tables];

CREATE NONCLUSTERED INDEX IX_MenuItems_RestaurantId ON MenuItems(RestaurantId);
CREATE NONCLUSTERED INDEX IX_Employees_RestaurantId ON Employees(RestaurantId);
CREATE NONCLUSTERED INDEX IX_Tables_RestaurantId ON [Tables](RestaurantId);