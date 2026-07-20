/* =====================================================================
   Restaurant Reservation Management System - Seed Data (DML)
   ---------------------------------------------------------------------
   Row counts: 50 Restaurants, 400 Customers, 100 Tables, 1000 MenuItems,
               100 Employees, 500 Reservations, 500 Orders, 1500 OrderItems.

   Design notes
   ------------
   * STRUCTURAL columns (which restaurant a table / menu item / employee /
     reservation belongs to) are assigned by formula so every foreign key
     is valid and every child row is tied to the correct restaurant:
        - Table  T  belongs to restaurant ((T-1) % 50) + 1
        - MenuItem I belongs to restaurant ((I-1) % 50) + 1
        - Employee E belongs to restaurant ((E-1) % 50) + 1  (2 per restaurant)
        - Reservation i uses restaurant ((i-1) % 50) + 1 and table ((i-1) % 100) + 1,
          which is guaranteed to belong to that same restaurant.
   * DESCRIPTIVE columns (names, address, price, hours, phone, ...) are varied
     with a DETERMINISTIC hash. Each row of #n carries 12 independent, well-mixed
     pseudo-random numbers (h1..h12) derived from HASHBYTES, so values are
     realistic and decorrelated yet fully reproducible (re-running the script
     produces the same data).
   * An order's employee is always a staff member OF the reservation's
     restaurant, and every order's line items are DISTINCT menu items of that
     restaurant (both were inconsistent in the first draft).
   ===================================================================== */
SET NOCOUNT ON;
DECLARE @today date = '2026-07-15';

/* ---- Lookup pools (decorrelated, realistic) ------------------------- */
DECLARE @First TABLE (id INT IDENTITY(1,1), v NVARCHAR(50));
INSERT INTO @First (v) VALUES
 ('James'),('Mary'),('John'),('Patricia'),('Robert'),('Jennifer'),('Michael'),('Linda'),
 ('David'),('Elizabeth'),('William'),('Barbara'),('Richard'),('Susan'),('Joseph'),('Jessica'),
 ('Thomas'),('Sarah'),('Charles'),('Karen'),('Daniel'),('Nancy'),('Matthew'),('Lisa'),
 ('Anthony'),('Betty'),('Mark'),('Sandra'),('Donald'),('Ashley'),('Steven'),('Emily'),
 ('Paul'),('Kimberly'),('Andrew'),('Donna'),('Joshua'),('Michelle'),('Kenneth'),('Carol');

DECLARE @Last TABLE (id INT IDENTITY(1,1), v NVARCHAR(50));
INSERT INTO @Last (v) VALUES
 ('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),
 ('Rodriguez'),('Martinez'),('Hernandez'),('Lopez'),('Gonzalez'),('Wilson'),('Anderson'),('Thomas'),
 ('Taylor'),('Moore'),('Jackson'),('Martin'),('Lee'),('Perez'),('Thompson'),('White'),
 ('Harris'),('Sanchez'),('Clark'),('Ramirez'),('Lewis'),('Robinson'),('Walker'),('Young'),
 ('Allen'),('King'),('Wright'),('Scott'),('Torres'),('Nguyen'),('Hill'),('Flores');

DECLARE @Domain TABLE (id INT IDENTITY(1,1), v NVARCHAR(30));
INSERT INTO @Domain (v) VALUES
 ('gmail.com'),('yahoo.com'),('outlook.com'),('hotmail.com'),('icloud.com'),('proton.me');

DECLARE @Area TABLE (id INT IDENTITY(1,1), v CHAR(3));
INSERT INTO @Area (v) VALUES ('212'),('415'),('312'),('713'),('602'),('617'),('206'),('305');

DECLARE @RAdj TABLE (id INT IDENTITY(1,1), v NVARCHAR(20));
INSERT INTO @RAdj (v) VALUES
 ('Golden'),('Silver'),('Copper'),('Rustic'),('Urban'),('Coastal'),('Blue'),('Crimson'),
 ('Ivory'),('Amber'),('Royal'),('Willow'),('Cedar'),('Emerald'),('Saffron'),('Olive');

DECLARE @RNoun TABLE (id INT IDENTITY(1,1), v NVARCHAR(20));
INSERT INTO @RNoun (v) VALUES
 ('Fork'),('Spoon'),('Lantern'),('Hearth'),('Garden'),('Barrel'),('Anchor'),('Basil'),
 ('Maple'),('Harbor'),('Pepper'),('Thyme'),('Skillet'),('Ember'),('Table'),('Vine');

DECLARE @RType TABLE (id INT IDENTITY(1,1), v NVARCHAR(20));
INSERT INTO @RType (v) VALUES
 ('Grill'),('Bistro'),('Tavern'),('Kitchen'),('Trattoria'),('Brasserie'),('Eatery'),
 ('Cantina'),('Steakhouse'),('Grotto');

DECLARE @Street TABLE (id INT IDENTITY(1,1), v NVARCHAR(30));
INSERT INTO @Street (v) VALUES
 ('Main St'),('Oak Ave'),('Maple Dr'),('Elm St'),('Cedar Ln'),('Pine St'),('Washington Ave'),('Lake Blvd'),
 ('Sunset Blvd'),('Highland Ave'),('Park Row'),('River Rd'),('Union St'),('Market St'),('Broadway'),('Chestnut St');

DECLARE @City TABLE (id INT IDENTITY(1,1), v NVARCHAR(30), st CHAR(2));
INSERT INTO @City (v, st) VALUES
 ('New York','NY'),('Los Angeles','CA'),('Chicago','IL'),('Houston','TX'),('Phoenix','AZ'),('Boston','MA'),
 ('Seattle','WA'),('Denver','CO'),('Miami','FL'),('Austin','TX'),('Portland','OR'),('Nashville','TN');

DECLARE @Hours TABLE (id INT IDENTITY(1,1), v NVARCHAR(100));
INSERT INTO @Hours (v) VALUES
 ('Mon-Sun 11:00-23:00'),
 ('Tue-Sun 12:00-22:00 (Closed Mon)'),
 ('Mon-Fri 09:00-21:00, Sat-Sun 10:00-23:00'),
 ('Daily 08:00-20:00'),
 ('Mon-Thu 11:30-22:00, Fri-Sat 11:30-00:00, Sun 11:30-21:00'),
 ('Wed-Mon 17:00-23:00 (Closed Tue)');

DECLARE @MPre TABLE (id INT IDENTITY(1,1), v NVARCHAR(20));
INSERT INTO @MPre (v) VALUES (''),('Classic '),('Signature '),('House '),('Chef''s ');

DECLARE @MAdj TABLE (id INT IDENTITY(1,1), v NVARCHAR(20));
INSERT INTO @MAdj (v) VALUES
 ('Grilled'),('Roasted'),('Crispy'),('Spicy'),('Creamy'),('Smoked'),('Braised'),('Pan-Seared'),
 ('Charred'),('Herb-Crusted'),('Honey-Glazed'),('Blackened');

DECLARE @MDish TABLE (id INT IDENTITY(1,1), v NVARCHAR(40));
INSERT INTO @MDish (v) VALUES
 ('Salmon'),('Ribeye'),('Chicken Alfredo'),('Margherita Pizza'),('Caesar Salad'),('Cheeseburger'),
 ('Lamb Curry'),('Mushroom Risotto'),('Fish Tacos'),('Veggie Wrap'),('Pork Belly'),('Shrimp Scampi'),
 ('Duck Confit'),('Beef Brisket'),('Tofu Stir-Fry'),('Eggplant Parmesan'),('Clam Chowder'),
 ('Steak Frites'),('BBQ Ribs'),('Falafel Bowl');

DECLARE @MDesc TABLE (id INT IDENTITY(1,1), v NVARCHAR(200));
INSERT INTO @MDesc (v) VALUES
 ('Chef''s signature dish, served with seasonal vegetables.'),
 ('A house favorite prepared with locally sourced ingredients.'),
 ('Slow-cooked to perfection and finished with fresh herbs.'),
 ('Served with a side of garlic mashed potatoes.'),
 ('Paired with a light citrus glaze and mixed greens.'),
 ('Hand-crafted daily by our head chef.'),
 ('A bold, flavorful take on a timeless classic.'),
 ('Comfort food with a modern twist.'),
 ('Grilled over an open flame for a smoky finish.'),
 ('Light, fresh, and perfect for sharing.');

DECLARE @Cap TABLE (id INT IDENTITY(1,1), v INT);   -- table capacities (weighted toward 4)
INSERT INTO @Cap (v) VALUES (2),(2),(4),(4),(4),(6),(6),(8),(10);

DECLARE @Rank TABLE (id INT IDENTITY(1,1), v NVARCHAR(30));
INSERT INTO @Rank (v) VALUES ('VIPOrdersWaiter'),('StandardWaiter'),('AssistantWaiter');

/* ---- Numbers helper (1..1500) with 12 independent hash streams ------
   hK = last 8 bytes of MD5('K:' + i), forced non-negative. Any hK % N is a
   well-distributed, collision-light, reproducible index in [0, N).          */
IF OBJECT_ID('tempdb..#n') IS NOT NULL DROP TABLE #n;
SELECT TOP (1500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
INTO #n
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

ALTER TABLE #n ADD
 h1 bigint, h2 bigint, h3 bigint, h4 bigint, h5 bigint, h6 bigint,
 h7 bigint, h8 bigint, h9 bigint, h10 bigint, h11 bigint, h12 bigint;

UPDATE #n SET
 h1  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('1:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h2  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('2:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h3  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('3:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h4  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('4:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h5  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('5:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h6  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('6:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h7  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('7:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h8  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('8:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h9  = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('9:',i)))  & 0x7FFFFFFFFFFFFFFF,
 h10 = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('10:',i))) & 0x7FFFFFFFFFFFFFFF,
 h11 = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('11:',i))) & 0x7FFFFFFFFFFFFFFF,
 h12 = CONVERT(BIGINT, HASHBYTES('MD5', CONCAT('12:',i))) & 0x7FFFFFFFFFFFFFFF
WHERE i BETWEEN 1 AND 1500;

/* =====================================================================
   Restaurants (50)
   ===================================================================== */
SET IDENTITY_INSERT [Restaurants] ON;
INSERT INTO [Restaurants] ([RestaurantId],[Name],[Address],[PhoneNumber],[OpeningHours])
SELECT n.i,
       ra.v + ' ' + rn.v + ' ' + rt.v,
       CAST(n.h8 % 900 + 100 AS varchar(4)) + ' ' + stt.v + ', '
              + ci.v + ', ' + ci.st + ' ' + CAST(n.h9 % 90000 + 10000 AS varchar(5)),
       '(' + ar.v + ') '
              + RIGHT('000'  + CAST(n.h10 % 1000  AS varchar(3)),3) + '-'
              + RIGHT('0000' + CAST(n.h11 % 10000 AS varchar(4)),4),
       oh.v
FROM #n n
JOIN @RAdj   ra  ON ra.id  = n.h1 % 16 + 1
JOIN @RNoun  rn  ON rn.id  = n.h2 % 16 + 1
JOIN @RType  rt  ON rt.id  = n.h3 % 10 + 1
JOIN @Street stt ON stt.id = n.h4 % 16 + 1
JOIN @City   ci  ON ci.id  = n.h5 % 12 + 1
JOIN @Area   ar  ON ar.id  = n.h6 % 8  + 1
JOIN @Hours  oh  ON oh.id  = n.h7 % 6  + 1
WHERE n.i <= 50;
SET IDENTITY_INSERT [Restaurants] OFF;

/* =====================================================================
   Customers (400)
   ===================================================================== */
SET IDENTITY_INSERT [Customers] ON;
INSERT INTO [Customers] ([CustomerId],[FirstName],[LastName],[Email],[PhoneNumber])
SELECT n.i, f.v, l.v,
       LOWER(f.v) + '.' + LOWER(l.v) + CAST(n.i AS varchar(4)) + '@' + dm.v,
       '(' + ar.v + ') '
              + RIGHT('000'  + CAST(n.h5 % 1000  AS varchar(3)),3) + '-'
              + RIGHT('0000' + CAST(n.h6 % 10000 AS varchar(4)),4)
FROM #n n
JOIN @First  f  ON f.id  = n.h1 % 40 + 1
JOIN @Last   l  ON l.id  = n.h2 % 40 + 1
JOIN @Domain dm ON dm.id = n.h3 % 6  + 1
JOIN @Area   ar ON ar.id = n.h4 % 8  + 1
WHERE n.i <= 400;
SET IDENTITY_INSERT [Customers] OFF;

/* =====================================================================
   Tables (100) - 2 per restaurant, varied capacity
   ===================================================================== */
SET IDENTITY_INSERT [Tables] ON;
INSERT INTO [Tables] ([TableId],[RestaurantId],[Capacity])
SELECT n.i, ((n.i-1)%50)+1, cp.v
FROM #n n
JOIN @Cap cp ON cp.id = n.h1 % 9 + 1
WHERE n.i <= 100;
SET IDENTITY_INSERT [Tables] OFF;

/* =====================================================================
   MenuItems (1000) - 20 per restaurant, varied name/desc/price
   ===================================================================== */
SET IDENTITY_INSERT [MenuItems] ON;
INSERT INTO [MenuItems] ([ItemId],[RestaurantId],[Name],[Description],[Price])
SELECT n.i,
       ((n.i-1)%50)+1,
       pr.v + ad.v + ' ' + di.v,
       ds.v,
       CAST(n.h5 % 41 + 8 AS decimal(10,2))
         + CASE n.h6 % 5 WHEN 0 THEN 0.49 WHEN 1 THEN 0.95
                WHEN 2 THEN 0.99 WHEN 3 THEN 0.00 ELSE 0.25 END
FROM #n n
JOIN @MPre  pr ON pr.id = n.h1 % 5  + 1
JOIN @MAdj  ad ON ad.id = n.h2 % 12 + 1
JOIN @MDish di ON di.id = n.h3 % 20 + 1
JOIN @MDesc ds ON ds.id = n.h4 % 10 + 1
WHERE n.i <= 1000;
SET IDENTITY_INSERT [MenuItems] OFF;

/* =====================================================================
   Employees (100) - 2 per restaurant.
   Slot A (id 1..50): a Manager for every 5th restaurant, else a waiter.
   Slot B (id 51..100): always a waiter (varied rank).
   => every restaurant has at least one waiter; 10 managers overall.
   ===================================================================== */
SET IDENTITY_INSERT [Employees] ON;
INSERT INTO [Employees] ([EmployeeId],[RestaurantId],[FirstName],[LastName],[Position])
SELECT n.i,
       ((n.i-1)%50)+1,
       f.v, l.v,
       CASE WHEN n.i <= 50 AND (n.i % 5) = 1 THEN 'Manager' ELSE wr.v END
FROM #n n
JOIN @First f  ON f.id  = n.h1 % 40 + 1
JOIN @Last  l  ON l.id  = n.h2 % 40 + 1
JOIN @Rank  wr ON wr.id = n.h3 % 3  + 1
WHERE n.i <= 100;
SET IDENTITY_INSERT [Employees] OFF;

/* =====================================================================
   Reservations (500)
   - Deterministic-random customer, restaurant/table kept consistent,
   - Dates spread from ~400 days in the past to ~160 days in the future,
   - PartySize never exceeds the chosen table's capacity.
   ===================================================================== */
SET IDENTITY_INSERT [Reservations] ON;
INSERT INTO [Reservations] ([ReservationId],[CustomerId],[RestaurantId],[TableId],[ReservationDate],[PartySize])
SELECT n.i,
       n.h1 % 400 + 1,
       ((n.i-1)%50)+1,
       ((n.i-1)%100)+1,
       DATEADD(minute, (n.h4 % 4) * 15,
         DATEADD(hour, n.h3 % 12 + 11,
           DATEADD(day, n.h2 % 560 - 400, CAST(@today AS datetime)))),
       CAST(n.h5 % t.Capacity + 1 AS int)
FROM #n n
JOIN [Tables] t ON t.TableId = ((n.i-1)%100)+1
WHERE n.i <= 500;
SET IDENTITY_INSERT [Reservations] OFF;

/* =====================================================================
   Orders (500) - only for reservations whose date is today or earlier.
   The employee is ALWAYS one of the two staff of the reservation's
   restaurant (R or R+50), so waiter/restaurant is always consistent.
   ===================================================================== */
SET IDENTITY_INSERT [Orders] ON;
;WITH past AS (
    SELECT ReservationId, RestaurantId, ReservationDate,
           ROW_NUMBER() OVER (ORDER BY ReservationId) AS rn,
           COUNT(*)     OVER ()                        AS cnt
    FROM [Reservations]
    WHERE ReservationDate <= CAST(@today AS datetime)
)
INSERT INTO [Orders] ([OrderId],[ReservationId],[EmployeeId],[OrderDate],[TotalAmount])
SELECT n.i,
       p.ReservationId,
       p.RestaurantId + 50 * (n.i % 2),                       -- staff member OF this restaurant
       DATEADD(minute, n.h1 % 90, p.ReservationDate),
       0                                                      -- filled in after line items
FROM #n n
JOIN past p ON p.rn = ((n.i-1) % p.cnt) + 1
WHERE n.i <= 500;
SET IDENTITY_INSERT [Orders] OFF;

/* =====================================================================
   OrderItems (1500) - exactly 3 DISTINCT menu items per order, each one
   belonging to the order's restaurant, with varied quantities.
   ===================================================================== */
SET IDENTITY_INSERT [OrderItems] ON;
INSERT INTO [OrderItems] ([OrderItemId],[OrderId],[ItemId],[Quantity])
SELECT ROW_NUMBER() OVER (ORDER BY o.OrderId, s.slot),
       o.OrderId,
       r.RestaurantId + 50 * ((o.OrderId*7 + s.slot*3) % 20),  -- 3 different items of restaurant R
       CAST((CONVERT(BIGINT, HASHBYTES('MD5', CONCAT(o.OrderId,':',s.slot)))
              & 0x7FFFFFFFFFFFFFFF) % 4 + 1 AS int)
FROM [Orders] o
JOIN [Reservations] r ON r.ReservationId = o.ReservationId
CROSS JOIN (VALUES (0),(1),(2)) s(slot);
SET IDENTITY_INSERT [OrderItems] OFF;

/* ---- Fill each order's TotalAmount from its line items --------------- */
UPDATE o
SET o.TotalAmount = t.amt
FROM [Orders] o
JOIN (
    SELECT oi.OrderId, SUM(oi.Quantity * m.Price) AS amt
    FROM [OrderItems] oi
    JOIN [MenuItems]  m ON m.ItemId = oi.ItemId
    GROUP BY oi.OrderId
) t ON t.OrderId = o.OrderId
WHERE t.amt IS NOT NULL;

DROP TABLE #n;

/* ---- Row-count summary ---------------------------------------------- */
SELECT 'Restaurants' AS TableName, COUNT(*) AS [Rows] FROM [Restaurants]
UNION ALL SELECT 'Customers',   COUNT(*) FROM [Customers]
UNION ALL SELECT 'Tables',      COUNT(*) FROM [Tables]
UNION ALL SELECT 'MenuItems',   COUNT(*) FROM [MenuItems]
UNION ALL SELECT 'Employees',   COUNT(*) FROM [Employees]
UNION ALL SELECT 'Reservations',COUNT(*) FROM [Reservations]
UNION ALL SELECT 'Orders',      COUNT(*) FROM [Orders]
UNION ALL SELECT 'OrderItems',  COUNT(*) FROM [OrderItems];
