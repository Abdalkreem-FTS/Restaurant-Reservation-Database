using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.Name)]
public class ViewTests(SqlServerFixture fixture)
{
    private async Task<IReadOnlyList<string>> ColumnsOf(string view) =>
        await fixture.QueryAsync<string>("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @view;", new { view });
    
    [Fact]
    public async Task ReservationsReport_Always_ExposesRestaurantAndCustomerPhonesSeparately()
    {
        var columns = await ColumnsOf("ReservationsReport");

        Assert.Contains("RestaurantPhone", columns);
        Assert.Contains("CustomerPhone", columns);
    }

    [Fact]
    public async Task ReservationsReport_Always_JoinsTheCorrectRestaurantAndCustomer()
    {
        var mismatches = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM ReservationsReport AS v
            JOIN Reservations AS r ON r.ReservationId = v.ReservationId
            WHERE v.RestaurantId <> r.RestaurantId OR v.CustomerId <> r.CustomerId;
            """);

        Assert.Equal(0, mismatches);
    }

    [Fact]
    public async Task ReservationsReport_Always_CoversEveryReservation()
    {
        var viewCount = await fixture.ScalarAsync<int>("SELECT COUNT(*) FROM ReservationsReport;");
        var tableCount = await fixture.ScalarAsync<int>("SELECT COUNT(*) FROM Reservations;");

        Assert.Equal(tableCount, viewCount);
    }

    [Fact]
    public async Task EmployeesDetails_Always_SeparatesFirstAndLastNameWithASpace()
    {
        var name = await fixture.ScalarAsync<string>(
            "SELECT TOP 1 EmployeeName FROM EmployeesDetails WHERE EmployeeId = 1;");

        Assert.NotNull(name);
        Assert.Contains(" ", name);
    }

    [Fact]
    public async Task EmployeesDetails_Always_CoversEveryEmployeeWithItsRestaurant()
    {
        var mismatches = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM EmployeesDetails AS v
            JOIN Employees AS e ON e.EmployeeId = v.EmployeeId
            WHERE v.RestaurantId <> e.RestaurantId;
            """);
        var viewCount = await fixture.ScalarAsync<int>("SELECT COUNT(*) FROM EmployeesDetails;");

        Assert.Equal(0, mismatches);
        Assert.Equal(100, viewCount);
    }
}
