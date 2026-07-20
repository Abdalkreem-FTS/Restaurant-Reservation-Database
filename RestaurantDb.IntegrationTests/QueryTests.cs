using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class QueryTests(SqlServerFixture fixture)
{
    [Fact]
    public async Task CustomerReservationsQuery_CustomerHasReservations_ReturnsOnlyThatCustomersReservations()
    {
        const int customerId = 34;
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("01_customer_reservations.sql"),
            new { CustomerId = customerId });

        var expected = await fixture.ScalarAsync<int>(
            "SELECT COUNT(*) FROM Reservations WHERE CustomerId = @customerId;", new { customerId });

        Assert.NotEmpty(rows);      
        Assert.Equal(expected, rows.Count);

        var returnedIds = rows.Select(r => (int)r.ReservationId).ToList();
        var foreign = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*) FROM Reservations
            WHERE ReservationId IN @returnedIds AND CustomerId <> @customerId;
            """, new { returnedIds, customerId });

        Assert.Equal(0, foreign);
    }

    [Fact]
    public async Task CustomerReservationsQuery_CustomerDoesNotExist_ReturnsNoRows()
    {
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("01_customer_reservations.sql"), new { CustomerId = 999_999 });

        Assert.Empty(rows);
    }

    [Fact]
    public async Task ManagersQuery_Always_ReturnsEveryManagerAndOnlyManagers()
    {
        var rows = await fixture.QueryRowsAsync(await SqlScript.QueryAsync("02_managers.sql"));

        var expected = await fixture.ScalarAsync<int>(
            "SELECT COUNT(*) FROM Employees WHERE Position = 'Manager';");

        Assert.NotEmpty(rows);
        Assert.Equal(expected, rows.Count);
        Assert.All(rows, r => Assert.Equal("Manager", (string)r.Position));
    }

    [Fact]
    public async Task ReservationOrdersQuery_ReservationGiven_ListsOnlyItemsFromItsOwnRestaurant()
    {
        const int reservationId = 7;
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("03_reservation_orders_and_items.sql"), new { ReservationId = reservationId });

        Assert.NotEmpty(rows);

        var itemIds = rows.Select(r => (int)r.ItemId).Distinct().ToList();
        var foreign = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*) FROM MenuItems
            WHERE ItemId IN @itemIds
              AND RestaurantId <> (SELECT RestaurantId FROM Reservations WHERE ReservationId = @reservationId);
            """, new { itemIds, reservationId });

        Assert.Equal(0, foreign);
    }

    [Fact]
    public async Task ReservationOrderedItemsQuery_ReservationGiven_NeverRepeatsAMenuItem()
    {
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("04_reservation_ordered_items.sql"), new { ReservationId = 7 });

        var itemIds = rows.Select(r => (int)r.ItemId).ToList();

        Assert.NotEmpty(itemIds);
        Assert.Equal(itemIds.Count, itemIds.Distinct().Count());
    }

    [Fact]
    public async Task AvgOrderAmountQuery_EmployeeHasOrders_MatchesAnIndependentAverage()
    {
        const int employeeId = 50;
        var row = (await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("05_avg_order_amount_by_employee.sql"), new { EmployeeId = employeeId })).Single();

        var expectedCount = await fixture.ScalarAsync<int>(
            "SELECT COUNT(*) FROM Orders WHERE EmployeeId = @employeeId;", new { employeeId });
        var expectedAverage = await fixture.ScalarAsync<decimal>(
            "SELECT AVG(TotalAmount) FROM Orders WHERE EmployeeId = @employeeId;", new { employeeId });

        Assert.True(expectedCount > 0, "Employee 50 should have orders, otherwise this test proves nothing.");
        Assert.Equal(expectedCount, (int)row.OrdersCount);
        Assert.Equal(expectedAverage, (decimal)row.AverageOrderAmount);
    }

    [Fact]
    public async Task ReservationsWithManyOrdersQuery_Always_ReturnsOnlyReservationsWithTwoOrMoreOrders()
    {
        var rows = await fixture.QueryRowsAsync(await SqlScript.QueryAsync("08_cte_reservations_2plus_orders.sql"));

        Assert.NotEmpty(rows);
        Assert.All(rows, r => Assert.True((int)r.OrdersCount >= 2));

        var expected = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*) FROM (
                SELECT ReservationId FROM Orders GROUP BY ReservationId HAVING COUNT(*) >= 2
            ) AS x;
            """);

        Assert.Equal(expected, rows.Count);
    }

    [Fact]
    public async Task RestaurantPopularityQuery_Always_ListsEveryRestaurantRankedDescending()
    {
        var rows = await fixture.QueryRowsAsync(await SqlScript.QueryAsync("09_restaurant_popularity.sql"));

        Assert.Equal(50, rows.Count);

        var counts = rows.Select(r => (int)r.ReservationsCount).ToList();
        Assert.Equal(counts.OrderByDescending(c => c).ToList(), counts);
    }

    [Fact]
    public async Task PopularMenuItemQuery_MonthGiven_ReturnsAtMostOneItemPerRestaurant()
    {
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("10_popular_menu_item_per_restaurant.sql"), new { Year = 2025, Month = 11 });

        Assert.NotEmpty(rows);

        var restaurantIds = rows.Select(r => (int)r.RestaurantId).ToList();
        Assert.Equal(restaurantIds.Count, restaurantIds.Distinct().Count());
    }

    [Fact]
    public async Task PopularMenuItemQuery_MonthHasNoOrders_ReturnsNoRows()
    {
        var rows = await fixture.QueryRowsAsync(
            await SqlScript.QueryAsync("10_popular_menu_item_per_restaurant.sql"), new { Year = 1990, Month = 1 });

        Assert.Empty(rows);
    }
}
