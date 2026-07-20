using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class FunctionTests(SqlServerFixture fixture)
{
    [Fact]
    public async Task fn_CalculateRevenue_RestaurantHasOrders_ReturnsSumOfItsOrderTotals()
    {
        const int restaurantId = 1;
        var actual = await fixture.ScalarAsync<decimal>("SELECT dbo.fn_CalculateRevenue(@restaurantId);", new { restaurantId });

        var expected = await fixture.ScalarAsync<decimal>("""
            SELECT ISNULL(SUM(o.TotalAmount), 0)
            FROM Reservations AS r
            JOIN Orders AS o ON o.ReservationId = r.ReservationId
            WHERE r.RestaurantId = @restaurantId;
            """, new { restaurantId });

        Assert.True(expected > 0, "Restaurant 1 should have revenue, otherwise this test proves nothing.");
        Assert.Equal(expected, actual);
    }

    [Fact]
    public async Task fn_CalculateRevenue_RestaurantHasNoOrders_ReturnsZeroNotNull()
    {
        var revenue = await fixture.ScalarAsync<decimal?>("SELECT dbo.fn_CalculateRevenue(999999);");

        Assert.Equal(0m, revenue);
    }

    [Fact]
    public async Task fn_CalculateEmployeeSalary_EmployeeIsManager_ReturnsZero()
    {
        var position = await fixture.ScalarAsync<string>("SELECT Position FROM Employees WHERE EmployeeId = 1;");
        var salary = await fixture.ScalarAsync<int>("SELECT dbo.fn_CalculateEmployeeSalary(1);");

        Assert.Equal("Manager", position);
        Assert.Equal(0, salary);
    }

    [Theory]
    [InlineData("VIPOrdersWaiter", 5)]
    [InlineData("StandardWaiter", 4)]
    [InlineData("AssistantWaiter", 3)]
    public async Task fn_CalculateEmployeeSalary_EmployeeIsWaiter_ReturnsOrderCountTimesRank(string position, int rank)
    {
        var employeeId = await fixture.ScalarAsync<int?>("""
            SELECT TOP 1 e.EmployeeId
            FROM Employees AS e
            WHERE e.Position = @position AND EXISTS (SELECT 1 FROM Orders o WHERE o.EmployeeId = e.EmployeeId)
            ORDER BY e.EmployeeId;
            """, new { position });

        Assert.True(employeeId.HasValue, $"No {position} with orders found, so this test proves nothing.");

        var orders = await fixture.ScalarAsync<int>(
            "SELECT COUNT(*) FROM Orders WHERE EmployeeId = @employeeId;", new { employeeId });
        var salary = await fixture.ScalarAsync<int>(
            "SELECT dbo.fn_CalculateEmployeeSalary(@employeeId);", new { employeeId });

        Assert.Equal(orders * rank, salary);
    }
    
    [Fact]
    public async Task fn_CalculateEmployeeSalary_EmployeeDoesNotExist_ReturnsZeroNotNull()
    {
        var salary = await fixture.ScalarAsync<int?>("SELECT dbo.fn_CalculateEmployeeSalary(999999);");

        Assert.Equal(0, salary);
    }
}
