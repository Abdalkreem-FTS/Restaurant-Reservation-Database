using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class SeedIntegrityTests(SqlServerFixture fixture)
{
    [Theory]
    [InlineData("Restaurants", 50)]
    [InlineData("Customers", 400)]
    [InlineData("[Tables]", 100)]
    [InlineData("MenuItems", 1000)]
    [InlineData("Employees", 100)]
    [InlineData("Reservations", 500)]
    [InlineData("Orders", 500)]
    [InlineData("OrderItems", 1500)]
    public async Task Seed_Always_GivesEachTableItsRequiredRowCount(string table, int expected)
    {
        var count = await fixture.ScalarAsync<int>($"SELECT COUNT(*) FROM {table};");

        Assert.Equal(expected, count);
    }

    [Fact]
    public async Task Seed_Always_EveryOrderIsTakenByItsOwnRestaurantsStaff()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM Orders AS o
            JOIN Reservations AS r ON r.ReservationId = o.ReservationId
            JOIN Employees AS e ON e.EmployeeId = o.EmployeeId
            WHERE e.RestaurantId <> r.RestaurantId;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_EveryOrderedItemBelongsToTheReservationsRestaurant()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM OrderItems AS oi
            JOIN Orders AS o ON o.OrderId = oi.OrderId
            JOIN Reservations AS r ON r.ReservationId = o.ReservationId
            JOIN MenuItems AS m ON m.ItemId = oi.ItemId
            WHERE m.RestaurantId <> r.RestaurantId;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_EveryReservationUsesATableFromItsOwnRestaurant()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM Reservations AS r
            JOIN [Tables] AS t ON t.TableId = r.TableId
            WHERE t.RestaurantId <> r.RestaurantId;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_PartySizeNeverExceedsTheTablesCapacity()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM Reservations AS r
            JOIN [Tables] AS t ON t.TableId = r.TableId
            WHERE r.PartySize > t.Capacity;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_OrdersOnlyExistForReservationsInThePast()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM Orders AS o
            JOIN Reservations AS r ON r.ReservationId = o.ReservationId
            WHERE r.ReservationDate > '2026-07-15';
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_NoOrderListsTheSameMenuItemTwice()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*) FROM (
                SELECT OrderId, ItemId
                FROM OrderItems
                GROUP BY OrderId, ItemId
                HAVING COUNT(*) > 1
            ) AS duplicates;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_EveryOrderTotalMatchesTheSumOfItsLineItems()
    {
        var violations = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM Orders AS o
            JOIN (
                SELECT oi.OrderId, SUM(oi.Quantity * m.Price) AS amount
                FROM OrderItems AS oi
                JOIN MenuItems AS m ON m.ItemId = oi.ItemId
                GROUP BY oi.OrderId
            ) AS t ON t.OrderId = o.OrderId
            WHERE o.TotalAmount <> t.amount;
            """);

        Assert.Equal(0, violations);
    }

    [Fact]
    public async Task Seed_Always_CustomerNamesAreVaried()
    {
        var distinct = await fixture.ScalarAsync<int>(
            "SELECT COUNT(DISTINCT FirstName + '|' + LastName) FROM Customers;");

        Assert.True(distinct > 300, $"Expected > 300 distinct customer names but found {distinct}.");
    }

    [Fact]
    public async Task Seed_Always_MenuItemNamesAreVaried()
    {
        var distinct = await fixture.ScalarAsync<int>("SELECT COUNT(DISTINCT [Name]) FROM MenuItems;");

        Assert.True(distinct > 600, $"Expected > 600 distinct menu item names but found {distinct}.");
    }
}
