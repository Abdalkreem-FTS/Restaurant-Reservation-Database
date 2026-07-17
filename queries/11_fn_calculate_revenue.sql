-- 11_fn_calculate_revenue.sql
CREATE OR REPLACE FUNCTION fn_CalculateRevenue(p_restaurant_id INT)
    RETURNS NUMERIC(18,2)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_result NUMERIC(18,2);
BEGIN
    SELECT SUM(o.TotalAmount) INTO v_result
    FROM Reservations AS r
             JOIN Orders       AS o ON r.ReservationId = o.ReservationId
    WHERE r.RestaurantId = p_restaurant_id;

    RETURN COALESCE(v_result, 0);
END;
$$;

SELECT 1 AS RestaurantId, fn_CalculateRevenue(1) AS TotalRevenue
UNION ALL
SELECT 2, fn_CalculateRevenue(2);