/*
   Requirement 19: Query plans AFTER indexing
   ---------------------------------------------------------------------
   The SAME five queries profiled in Requirement 17, re-checked after the
   indexes from Requirement 18 exist:

       3  - queries/03_reservation_orders_and_items.sql
       5  - queries/05_avg_order_amount_by_employee.sql
       8  - queries/08_cte_reservations_2plus_orders.sql
       9  - queries/09_restaurant_popularity.sql
       10 - queries/10_popular_menu_item_per_restaurant.sql
 */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

PRINT 'STATISTICS IO/TIME are ON for this session (after indexing).';
PRINT 'Make sure 18_indexes.sql has been run, then re-run these five files';
PRINT 'in this SAME session and compare with Requirement 17:';
PRINT '   queries/03_reservation_orders_and_items.sql';
PRINT '   queries/05_avg_order_amount_by_employee.sql';
PRINT '   queries/08_cte_reservations_2plus_orders.sql';
PRINT '   queries/09_restaurant_popularity.sql';
PRINT '   queries/10_popular_menu_item_per_restaurant.sql';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
