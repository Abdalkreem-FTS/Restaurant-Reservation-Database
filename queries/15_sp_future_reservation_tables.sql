-- 15_sp_future_reservation_tables.sql
CREATE OR REPLACE FUNCTION sp_FutureReservationTables()
    RETURNS TABLE (
                      table_id        INT,
                      restaurant_id   INT,
                      restaurant_name VARCHAR,
                      address         VARCHAR,
                      phone_number    VARCHAR,
                      opening_hours   VARCHAR
                  )
    LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS FutureTables;

    CREATE TEMP TABLE FutureTables AS
    SELECT DISTINCT r.TableId, r.RestaurantId
    FROM Reservations AS r
    WHERE r.ReservationDate > NOW();

    RETURN QUERY
        SELECT ft.TableId, rt.RestaurantId, rt.Name, rt.Address, rt.PhoneNumber, rt.OpeningHours
        FROM FutureTables AS ft
                 JOIN Restaurants  AS rt ON rt.RestaurantId = ft.RestaurantId
        ORDER BY rt.RestaurantId, ft.TableId;

    DROP TABLE FutureTables;
END;
$$;

SELECT * FROM sp_FutureReservationTables();