# Restaurant Reservation Management System (PostgreSQL)

A PostgreSQL database for a group of restaurants: menus, tables, customers,
reservations, orders and staff. Contains the schema, seed data, and the queries,
views, functions and trigger required by the project.

## Layout

| Path                     | Contents                                                  |
| ------------------------ | --------------------------------------------------------- |
| `00_create_database.sql` | Creates the database (drops it first if it exists).       |
| `01_create_tables.sql`   | The 8 tables and their foreign keys.                      |
| `02_seed_data.sql`       | Seed data for every table.                                |
| `queries/`               | Requirements 1–16, one file each.                         |
| `query-plans/`           | Requirements 17–19 and the before/after plan screenshots. |
| `diagrams/`              | ER diagram.                                               |

## How to run

1. Run `00_create_database.sql` against the **`postgres`** database — PostgreSQL
   cannot drop a database you are connected to.
2. Connect to the new database: `\c restaurantreservationdb`
3. Run `01_create_tables.sql`, then `02_seed_data.sql`.
4. Run any file in `queries/`.

The seed assumes empty tables, so re-seeding means re-running `00`. Views,
functions and the trigger use `CREATE OR REPLACE`, so the `queries/` files can be
re-run freely.

Identifiers are unquoted, so PostgreSQL folds them to lower case
(`RestaurantId` becomes `restaurantid`). Queries can still be written in either case.

## Schema

- **Restaurants** — parent of Tables, MenuItems, Employees and Reservations.
- **Customers** — independent.
- **Tables**, **MenuItems**, **Employees** — each belongs to one restaurant.
- **Reservations** — reference a Customer, a Restaurant and a Table.
- **Orders** — reference a Reservation and the Employee who took it.
- **OrderItems** — link an Order to a MenuItem with a Quantity.

Full model with keys and cardinalities: `diagrams/er_diagram.png`.

## Seed data

50 restaurants, 400 customers, 100 tables, 1000 menu items, 100 employees,
500 reservations, 500 orders, 1500 order items.

Values come from lookup pools indexed by a deterministic `md5` hash, so the data
is varied but reproducible. Every child row belongs to the correct restaurant,
orders exist only for reservations in the past, and a party size never exceeds
its table's capacity.

## Requirements

| #   | File                                      | What it does                                                                 |
| --- | ----------------------------------------- | ---------------------------------------------------------------------------- |
| 1   | `01_customer_reservations.sql`            | Reservations for a given customer.                                           |
| 2   | `02_managers.sql`                         | Employees with the `Manager` position.                                       |
| 3   | `03_reservation_orders_and_items.sql`     | Orders on a given reservation with their menu items.                         |
| 4   | `04_reservation_ordered_items.sql`        | Distinct menu items ordered by a given reservation.                          |
| 5   | `05_avg_order_amount_by_employee.sql`     | Average order amount handled by a given employee.                            |
| 6   | `06_view_reservations_report.sql`         | **View** — reservations + restaurant + customer details.                     |
| 7   | `07_view_employee_details.sql`            | **View** — employees + their restaurant details.                             |
| 8   | `08_cte_reservations_2plus_orders.sql`    | **CTE** — reservations with 2+ orders.                                       |
| 9   | `09_restaurant_popularity.sql`            | Restaurants ranked by reservation frequency.                                 |
| 10  | `10_popular_menu_item_per_restaurant.sql` | Most popular menu item per restaurant for a month.                           |
| 11  | `11_fn_calculate_revenue.sql`             | **Function** `fn_CalculateRevenue(restaurant_id)`.                           |
| 12  | `12_fn_calculate_employee_salary.sql`     | **Function** `fn_CalculateEmployeeSalary(employee_id)` = orders × rank.      |
| 13  | `13_sp_reserved_tables_report.sql`        | **Function** `sp_ReservedTablesReport(start, end)` returning a table.        |
| 14  | `14_sp_add_new_order.sql`                 | **Function** `sp_AddNewOrder` — validates, inserts, returns the new OrderId. |
| 15  | `15_sp_future_reservation_tables.sql`     | **Function** — tables with future reservations, via a temp table.            |
| 16  | `16_trg_audit_reservation.sql`            | **Trigger** — logs to `AuditLog` when a reservation is inserted.             |
| 17  | `17_query_plans_before_indexes.sql`       | Query plans before indexing.                                                 |
| 18  | `18_indexes.sql`                          | Indexes on the foreign keys and filter columns.                              |
| 19  | `19_query_plans_after_indexes.sql`        | The same query plans after indexing.                                         |

Requirements 13–15 are functions rather than procedures because a PostgreSQL
`PROCEDURE` cannot return a result set.

## Query plans & indexing (17–19)

PostgreSQL has no session-level `STATISTICS IO`. Each plan comes from
`EXPLAIN (ANALYZE, BUFFERS)` — or Explain Analyze in DataGrip — run against the
five selected queries (3, 5, 8, 9, 10). `18_indexes.sql` creates the indexes and
finishes with `ANALYZE` so the planner has fresh statistics and will actually
consider them. Screenshots are in `query-plans/before-indexes/` and
`query-plans/after-indexes/`.

Reading the plans: `Seq Scan` is a full table scan, `Index Scan` means an index
was used, and `Index Only Scan` means an `INCLUDE` index covered the query
entirely. `Buffers: shared hit` is the equivalent of SQL Server's logical reads.
