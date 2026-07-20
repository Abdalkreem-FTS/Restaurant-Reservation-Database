/*
   Requirement 17: Query plans BEFORE indexing
   ---------------------------------------------------------------------
   Five complex queries were selected for plan analysis (by requirement no.):

       3  - orders + menu items for one reservation
            queries/03_reservation_orders_and_items.sql
       5  - average order amount for one employee
            queries/05_avg_order_amount_by_employee.sql
       8  - reservations with 2 or more orders (CTE)
            queries/08_cte_reservations_2plus_orders.sql
       9  - restaurants ranked by reservation frequency
            queries/09_restaurant_popularity.sql
       10 - most popular menu item per restaurant for a month
            queries/10_popular_menu_item_per_restaurant.sql
 */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT 'STATISTICS IO/TIME are ON for this session (before indexing).';
PRINT 'Now run these five files in this SAME session:';
PRINT '   queries/03_reservation_orders_and_items.sql';
PRINT '   queries/05_avg_order_amount_by_employee.sql';
PRINT '   queries/08_cte_reservations_2plus_orders.sql';
PRINT '   queries/09_restaurant_popularity.sql';
PRINT '   queries/10_popular_menu_item_per_restaurant.sql';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
