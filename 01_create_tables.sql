CREATE TABLE Restaurants (
    RestaurantId INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(100)  NOT NULL,
    [Address] NVARCHAR(255),
    PhoneNumber VARCHAR(20),
    OpeningHours NVARCHAR(100)
);

CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255),
    PhoneNumber VARCHAR(20)
);

CREATE TABLE [Tables] (
    TableId INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantId INT NOT NULL,
    Capacity INT NOT NULL,
    CONSTRAINT FK_Tables_Restaurant FOREIGN KEY (RestaurantId) REFERENCES Restaurants(RestaurantId)
);

CREATE TABLE MenuItems (
    ItemId INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantId INT NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500),
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_MenuItems_Restaurant FOREIGN KEY (RestaurantId) REFERENCES Restaurants(RestaurantId)
);

CREATE TABLE Employees (
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantId INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_Employees_Restaurant FOREIGN KEY (RestaurantId) REFERENCES Restaurants(RestaurantId)
);

CREATE TABLE Reservations (
    ReservationId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    RestaurantId INT NOT NULL,
    TableId INT NOT NULL,
    ReservationDate DATETIME NOT NULL,
    PartySize INT NOT NULL,
    CONSTRAINT FK_Reservations_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT FK_Reservations_Restaurant FOREIGN KEY (RestaurantId) REFERENCES Restaurants(RestaurantId),
    CONSTRAINT FK_Reservations_Table FOREIGN KEY (TableId) REFERENCES [Tables](TableId)
);

CREATE TABLE Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    EmployeeId INT NOT NULL,
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Orders_Reservation FOREIGN KEY (ReservationId) REFERENCES Reservations(ReservationId),
    CONSTRAINT FK_Orders_Employee FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);

CREATE TABLE OrderItems (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ItemId INT NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderItems_MenuItem FOREIGN KEY (ItemId) REFERENCES MenuItems(ItemId)
);

-- Written to by the trigger in queries/16_trg_audit_reservation.sql. Kept here so that
-- file contains only the trigger. Intentionally has no foreign keys: an audit row must
-- survive even if the reservation it describes is later removed.
CREATE TABLE AuditLog (
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantId INT,
    TableId INT,
    ReservationDate DATETIME,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE()
);