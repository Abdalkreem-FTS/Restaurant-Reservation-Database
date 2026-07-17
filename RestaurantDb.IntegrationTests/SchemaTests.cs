using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.Name)]
public class SchemaTests(SqlServerFixture fixture)
{
    [Theory]
    [InlineData("Restaurants")]
    [InlineData("Customers")]
    [InlineData("Tables")]
    [InlineData("MenuItems")]
    [InlineData("Employees")]
    [InlineData("Reservations")]
    [InlineData("Orders")]
    [InlineData("OrderItems")]
    public async Task Schema_AfterCreation_TableExists(string table)
    {
        var count = await fixture.ScalarAsync<int>(
            "SELECT COUNT(*) FROM sys.tables WHERE name = @table;", new { table });

        Assert.Equal(1, count);
    }

    [Fact]
    public async Task Schema_AfterCreation_DeclaresEveryForeignKey()
    {
        var count = await fixture.ScalarAsync<int>("SELECT COUNT(*) FROM sys.foreign_keys;");

        Assert.Equal(10, count);
    }

    [Fact]
    public async Task Schema_AfterCreation_ReservationDateKeepsItsTimeComponent()
    {
        var type = await fixture.ScalarAsync<string>("""
            SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'Reservations' AND COLUMN_NAME = 'ReservationDate';
            """);

        Assert.Equal("datetime", type);
    }
}
