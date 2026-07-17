-- =====================================================================
-- Seed data (PostgreSQL). Same design as the SQL Server version:
--   * structural columns by formula  -> every child row keeps the correct restaurant
--   * descriptive columns by deterministic hash -> varied but reproducible
-- =====================================================================

-- ---- 12 independent deterministic pseudo-random streams per row -------
-- ('x' || 15 hex chars)::bit(60)::bigint  is always non-negative.
DROP TABLE IF EXISTS n;
CREATE TEMP TABLE n AS
SELECT i,
       ('x' || substr(md5('1:'  || i), 1, 15))::bit(60)::bigint AS h1,
       ('x' || substr(md5('2:'  || i), 1, 15))::bit(60)::bigint AS h2,
       ('x' || substr(md5('3:'  || i), 1, 15))::bit(60)::bigint AS h3,
       ('x' || substr(md5('4:'  || i), 1, 15))::bit(60)::bigint AS h4,
       ('x' || substr(md5('5:'  || i), 1, 15))::bit(60)::bigint AS h5,
       ('x' || substr(md5('6:'  || i), 1, 15))::bit(60)::bigint AS h6,
       ('x' || substr(md5('7:'  || i), 1, 15))::bit(60)::bigint AS h7,
       ('x' || substr(md5('8:'  || i), 1, 15))::bit(60)::bigint AS h8,
       ('x' || substr(md5('9:'  || i), 1, 15))::bit(60)::bigint AS h9,
       ('x' || substr(md5('10:' || i), 1, 15))::bit(60)::bigint AS h10,
       ('x' || substr(md5('11:' || i), 1, 15))::bit(60)::bigint AS h11,
       ('x' || substr(md5('12:' || i), 1, 15))::bit(60)::bigint AS h12
FROM generate_series(1, 1500) AS i;

-- ---- lookup pools (one row of arrays; arrays are 1-based) -------------
DROP TABLE IF EXISTS pools;
CREATE TEMP TABLE pools AS SELECT
                               ARRAY['James','Mary','John','Patricia','Robert','Jennifer','Michael','Linda',
                                   'David','Elizabeth','William','Barbara','Richard','Susan','Joseph','Jessica',
                                   'Thomas','Sarah','Charles','Karen','Daniel','Nancy','Matthew','Lisa',
                                   'Anthony','Betty','Mark','Sandra','Donald','Ashley','Steven','Emily',
                                   'Paul','Kimberly','Andrew','Donna','Joshua','Michelle','Kenneth','Carol']::text[] AS firsts,
                               ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis',
                                   'Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas',
                                   'Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White',
                                   'Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young',
                                   'Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores']::text[] AS lasts,
                               ARRAY['gmail.com','yahoo.com','outlook.com','hotmail.com','icloud.com','proton.me']::text[] AS domains,
                               ARRAY['212','415','312','713','602','617','206','305']::text[] AS areas,
                               ARRAY['Golden','Silver','Copper','Rustic','Urban','Coastal','Blue','Crimson',
                                   'Ivory','Amber','Royal','Willow','Cedar','Emerald','Saffron','Olive']::text[] AS radj,
                               ARRAY['Fork','Spoon','Lantern','Hearth','Garden','Barrel','Anchor','Basil',
                                   'Maple','Harbor','Pepper','Thyme','Skillet','Ember','Table','Vine']::text[] AS rnoun,
                               ARRAY['Grill','Bistro','Tavern','Kitchen','Trattoria','Brasserie','Eatery',
                                   'Cantina','Steakhouse','Grotto']::text[] AS rtype,
                               ARRAY['Main St','Oak Ave','Maple Dr','Elm St','Cedar Ln','Pine St','Washington Ave','Lake Blvd',
                                   'Sunset Blvd','Highland Ave','Park Row','River Rd','Union St','Market St','Broadway','Chestnut St']::text[] AS streets,
                               ARRAY['New York','Los Angeles','Chicago','Houston','Phoenix','Boston',
                                   'Seattle','Denver','Miami','Austin','Portland','Nashville']::text[] AS cities,
                               ARRAY['NY','CA','IL','TX','AZ','MA','WA','CO','FL','TX','OR','TN']::text[] AS states,
                               ARRAY['Mon-Sun 11:00-23:00',
                                   'Tue-Sun 12:00-22:00 (Closed Mon)',
                                   'Mon-Fri 09:00-21:00, Sat-Sun 10:00-23:00',
                                   'Daily 08:00-20:00',
                                   'Mon-Thu 11:30-22:00, Fri-Sat 11:30-00:00, Sun 11:30-21:00',
                                   'Wed-Mon 17:00-23:00 (Closed Tue)']::text[] AS hours,
                               ARRAY['','Classic ','Signature ','House ','Chef''s ']::text[] AS mpre,
                               ARRAY['Grilled','Roasted','Crispy','Spicy','Creamy','Smoked','Braised','Pan-Seared',
                                   'Charred','Herb-Crusted','Honey-Glazed','Blackened']::text[] AS madj,
                               ARRAY['Salmon','Ribeye','Chicken Alfredo','Margherita Pizza','Caesar Salad','Cheeseburger',
                                   'Lamb Curry','Mushroom Risotto','Fish Tacos','Veggie Wrap','Pork Belly','Shrimp Scampi',
                                   'Duck Confit','Beef Brisket','Tofu Stir-Fry','Eggplant Parmesan','Clam Chowder',
                                   'Steak Frites','BBQ Ribs','Falafel Bowl']::text[] AS mdish,
                               ARRAY['Chef''s signature dish, served with seasonal vegetables.',
                                   'A house favorite prepared with locally sourced ingredients.',
                                   'Slow-cooked to perfection and finished with fresh herbs.',
                                   'Served with a side of garlic mashed potatoes.',
                                   'Paired with a light citrus glaze and mixed greens.',
                                   'Hand-crafted daily by our head chef.',
                                   'A bold, flavorful take on a timeless classic.',
                                   'Comfort food with a modern twist.',
                                   'Grilled over an open flame for a smoky finish.',
                                   'Light, fresh, and perfect for sharing.']::text[] AS mdesc,
                               ARRAY[2,2,4,4,4,6,6,8,10]::int[] AS caps,
                               ARRAY['VIPOrdersWaiter','StandardWaiter','AssistantWaiter']::text[] AS ranks;

-- ---- Restaurants (50) -------------------------------------------------
INSERT INTO Restaurants (RestaurantId, Name, Address, PhoneNumber, OpeningHours)
SELECT n.i,
       p.radj[(n.h1 % 16 + 1)::int] || ' ' || p.rnoun[(n.h2 % 16 + 1)::int] || ' ' || p.rtype[(n.h3 % 10 + 1)::int],
       (n.h8 % 900 + 100)::text || ' ' || p.streets[(n.h4 % 16 + 1)::int] || ', '
           || p.cities[(n.h5 % 12 + 1)::int] || ', ' || p.states[(n.h5 % 12 + 1)::int] || ' '
           || (n.h9 % 90000 + 10000)::text,
       '(' || p.areas[(n.h6 % 8 + 1)::int] || ') ' || lpad((n.h10 % 1000)::text, 3, '0')
           || '-' || lpad((n.h11 % 10000)::text, 4, '0'),
       p.hours[(n.h7 % 6 + 1)::int]
FROM n CROSS JOIN pools p
WHERE n.i <= 50;

-- ---- Customers (400) --------------------------------------------------
INSERT INTO Customers (CustomerId, FirstName, LastName, Email, PhoneNumber)
SELECT n.i,
       p.firsts[(n.h1 % 40 + 1)::int],
       p.lasts [(n.h2 % 40 + 1)::int],
       lower(p.firsts[(n.h1 % 40 + 1)::int]) || '.' || lower(p.lasts[(n.h2 % 40 + 1)::int])
           || n.i || '@' || p.domains[(n.h3 % 6 + 1)::int],
       '(' || p.areas[(n.h4 % 8 + 1)::int] || ') ' || lpad((n.h5 % 1000)::text, 3, '0')
           || '-' || lpad((n.h6 % 10000)::text, 4, '0')
FROM n CROSS JOIN pools p
WHERE n.i <= 400;

-- ---- Tables (100) - 2 per restaurant ---------------------------------
INSERT INTO Tables (TableId, RestaurantId, Capacity)
SELECT n.i, ((n.i - 1) % 50) + 1, p.caps[(n.h1 % 9 + 1)::int]
FROM n CROSS JOIN pools p
WHERE n.i <= 100;

-- ---- MenuItems (1000) - 20 per restaurant ----------------------------
INSERT INTO MenuItems (ItemId, RestaurantId, Name, Description, Price)
SELECT n.i,
       ((n.i - 1) % 50) + 1,
       p.mpre[(n.h1 % 5 + 1)::int] || p.madj[(n.h2 % 12 + 1)::int] || ' ' || p.mdish[(n.h3 % 20 + 1)::int],
       p.mdesc[(n.h4 % 10 + 1)::int],
       ((n.h5 % 41 + 8)::numeric
           + CASE n.h6 % 5 WHEN 0 THEN 0.49 WHEN 1 THEN 0.95
                           WHEN 2 THEN 0.99 WHEN 3 THEN 0.00 ELSE 0.25 END)::numeric(10,2)
FROM n CROSS JOIN pools p
WHERE n.i <= 1000;

-- ---- Employees (100) - 2 per restaurant, 10 managers -----------------
INSERT INTO Employees (EmployeeId, RestaurantId, FirstName, LastName, Position)
SELECT n.i,
       ((n.i - 1) % 50) + 1,
       p.firsts[(n.h1 % 40 + 1)::int],
       p.lasts [(n.h2 % 40 + 1)::int],
       CASE WHEN n.i <= 50 AND (n.i % 5) = 1 THEN 'Manager'
            ELSE p.ranks[(n.h3 % 3 + 1)::int] END
FROM n CROSS JOIN pools p
WHERE n.i <= 100;

-- ---- Reservations (500) - party size never exceeds capacity ----------
INSERT INTO Reservations (ReservationId, CustomerId, RestaurantId, TableId, ReservationDate, PartySize)
SELECT n.i,
       (n.h1 % 400 + 1)::int,
       ((n.i - 1) % 50) + 1,
       ((n.i - 1) % 100) + 1,
       DATE '2026-07-15'
           + ((n.h2 % 560) - 400) * INTERVAL '1 day'
           + ((n.h3 % 12) + 11)   * INTERVAL '1 hour'
           + ((n.h4 % 4) * 15)    * INTERVAL '1 minute',
       (n.h5 % t.Capacity + 1)::int
FROM n
         JOIN Tables t ON t.TableId = ((n.i - 1) % 100) + 1
WHERE n.i <= 500;

-- ---- Orders (500) - past reservations only; waiter of that restaurant -
WITH past AS (
    SELECT ReservationId, RestaurantId, ReservationDate,
           ROW_NUMBER() OVER (ORDER BY ReservationId) AS rn,
           COUNT(*)     OVER ()                       AS cnt
    FROM Reservations
    WHERE ReservationDate <= TIMESTAMP '2026-07-15 00:00:00'
)
INSERT INTO Orders (OrderId, ReservationId, EmployeeId, OrderDate, TotalAmount)
SELECT n.i,
       p.ReservationId,
       (p.RestaurantId + 50 * (n.i % 2))::int,
       p.ReservationDate + (n.h1 % 90) * INTERVAL '1 minute',
       0
FROM n
         JOIN past p ON p.rn = ((n.i - 1) % p.cnt) + 1
WHERE n.i <= 500;

-- ---- OrderItems (1500) - 3 distinct items of that restaurant per order
INSERT INTO OrderItems (OrderItemId, OrderId, ItemId, Quantity)
SELECT (ROW_NUMBER() OVER (ORDER BY o.OrderId, s.slot))::int,
       o.OrderId,
       (r.RestaurantId + 50 * ((o.OrderId * 7 + s.slot * 3) % 20))::int,
       (('x' || substr(md5(o.OrderId || ':' || s.slot), 1, 15))::bit(60)::bigint % 4 + 1)::int
FROM Orders o
         JOIN Reservations r ON r.ReservationId = o.ReservationId
         CROSS JOIN (VALUES (0),(1),(2)) AS s(slot);

-- ---- fill each order's total from its line items ----------------------
UPDATE Orders o
SET TotalAmount = t.amt
FROM (
         SELECT oi.OrderId, SUM(oi.Quantity * m.Price) AS amt
         FROM OrderItems oi
                  JOIN MenuItems  m ON m.ItemId = oi.ItemId
         GROUP BY oi.OrderId
     ) t
WHERE t.OrderId = o.OrderId;

-- ---- re-sync the identity sequences after explicit-ID inserts ---------
SELECT setval(pg_get_serial_sequence('restaurants','restaurantid'), (SELECT MAX(RestaurantId) FROM Restaurants));
SELECT setval(pg_get_serial_sequence('customers','customerid'),     (SELECT MAX(CustomerId)   FROM Customers));
SELECT setval(pg_get_serial_sequence('tables','tableid'),           (SELECT MAX(TableId)      FROM Tables));
SELECT setval(pg_get_serial_sequence('menuitems','itemid'),         (SELECT MAX(ItemId)       FROM MenuItems));
SELECT setval(pg_get_serial_sequence('employees','employeeid'),     (SELECT MAX(EmployeeId)   FROM Employees));
SELECT setval(pg_get_serial_sequence('reservations','reservationid'),(SELECT MAX(ReservationId) FROM Reservations));
SELECT setval(pg_get_serial_sequence('orders','orderid'),           (SELECT MAX(OrderId)      FROM Orders));
SELECT setval(pg_get_serial_sequence('orderitems','orderitemid'),   (SELECT MAX(OrderItemId)  FROM OrderItems));

DROP TABLE n;
DROP TABLE pools;

-- ---- row-count summary ------------------------------------------------
SELECT 'Restaurants' AS table_name, COUNT(*) FROM Restaurants
UNION ALL SELECT 'Customers',    COUNT(*) FROM Customers
UNION ALL SELECT 'Tables',       COUNT(*) FROM Tables
UNION ALL SELECT 'MenuItems',    COUNT(*) FROM MenuItems
UNION ALL SELECT 'Employees',    COUNT(*) FROM Employees
UNION ALL SELECT 'Reservations', COUNT(*) FROM Reservations
UNION ALL SELECT 'Orders',       COUNT(*) FROM Orders
UNION ALL SELECT 'OrderItems',   COUNT(*) FROM OrderItems;