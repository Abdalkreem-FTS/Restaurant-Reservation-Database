-- 10_popular_menu_item_per_restaurant.sql
WITH ItemPopularity AS (
    SELECT r.RestaurantId, oi.ItemId, SUM(oi.Quantity) AS UnitsSold,
           ROW_NUMBER() OVER (PARTITION BY r.RestaurantId
               ORDER BY SUM(oi.Quantity) DESC, oi.ItemId) AS PopularityRank
    FROM Reservations AS r
             JOIN Orders     AS o  ON r.ReservationId = o.ReservationId
             JOIN OrderItems AS oi ON o.OrderId       = oi.OrderId
    WHERE EXTRACT(YEAR  FROM o.OrderDate) = 2025
      AND EXTRACT(MONTH FROM o.OrderDate) = 11
    GROUP BY r.RestaurantId, oi.ItemId
)
SELECT p.RestaurantId, p.ItemId, m.Name AS ItemName, p.UnitsSold
FROM ItemPopularity AS p
         JOIN MenuItems      AS m ON m.ItemId = p.ItemId
WHERE p.PopularityRank = 1
ORDER BY p.RestaurantId;