-- 13_sp_reserved_tables_report.sql
CREATE OR REPLACE FUNCTION sp_ReservedTablesReport(p_start_date TIMESTAMP, p_end_date TIMESTAMP)
    RETURNS TABLE (
                      table_id         INT,
                      restaurant_id    INT,
                      restaurant_name  VARCHAR,
                      reservation_date TIMESTAMP,
                      party_size       INT,
                      capacity         INT,
                      address          VARCHAR,
                      phone_number     VARCHAR,
                      opening_hours    VARCHAR
                  )
    LANGUAGE sql
AS $$
SELECT t.TableId, rt.RestaurantId, rt.Name, res.ReservationDate,
       res.PartySize, t.Capacity, rt.Address, rt.PhoneNumber, rt.OpeningHours
FROM Reservations AS res
         JOIN Tables       AS t  ON res.TableId      = t.TableId
         JOIN Restaurants  AS rt ON res.RestaurantId = rt.RestaurantId
WHERE res.ReservationDate BETWEEN p_start_date AND p_end_date
ORDER BY res.ReservationDate, rt.RestaurantId, t.TableId;
$$;

SELECT * FROM sp_ReservedTablesReport('2026-01-01', '2026-03-31');