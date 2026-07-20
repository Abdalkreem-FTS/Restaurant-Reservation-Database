using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class IndexTests(SqlServerFixture fixture)
{
    [Theory]
    [InlineData("IX_Reservations_CustomerId")]
    [InlineData("IX_Reservations_RestaurantId")]
    [InlineData("IX_Reservations_TableId")]
    [InlineData("IX_Reservations_ReservationDate")]
    [InlineData("IX_Orders_ReservationId")]
    [InlineData("IX_Orders_EmployeeId")]
    [InlineData("IX_Orders_OrderDate")]
    [InlineData("IX_OrderItems_OrderId")]
    [InlineData("IX_OrderItems_ItemId")]
    [InlineData("IX_MenuItems_RestaurantId")]
    [InlineData("IX_Employees_RestaurantId")]
    [InlineData("IX_Tables_RestaurantId")]
    public async Task IndexScript_AfterRun_CreatesTheExpectedIndex(string name)
    {
        var count = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM sys.indexes AS i
            JOIN sys.tables AS t ON t.object_id = i.object_id
            WHERE i.name = @name AND t.is_ms_shipped = 0;
            """, new { name });

        Assert.Equal(1, count);
    }

    [Theory]
    [InlineData("IX_Reservations_CustomerId", "CustomerId")]
    [InlineData("IX_Orders_EmployeeId", "EmployeeId")]
    [InlineData("IX_Orders_OrderDate", "OrderDate")]
    [InlineData("IX_OrderItems_OrderId", "OrderId")]
    public async Task IndexScript_AfterRun_KeysTheIndexOnTheExpectedColumn(string index, string column)
    {
        var keys = await KeyColumnsOf(index);

        Assert.Equal([column], keys);
    }

    [Theory]
    [InlineData("IX_Orders_EmployeeId", "TotalAmount")]
    [InlineData("IX_Orders_ReservationId", "TotalAmount")]
    [InlineData("IX_Orders_OrderDate", "ReservationId")]
    [InlineData("IX_OrderItems_OrderId", "Quantity")]
    [InlineData("IX_Reservations_ReservationDate", "PartySize")]
    public async Task IndexScript_AfterRun_IncludesTheExpectedCoveringColumn(string index, string included)
    {
        var includes = await IncludedColumnsOf(index);

        Assert.Contains(included, includes);
    }

    [Fact]
    public async Task IndexScript_RunTwice_IsIdempotent()
    {
        await fixture.ExecuteAsync(await SqlScript.QueryPlanAsync("18_indexes.sql"));

        var count = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*)
            FROM sys.indexes AS i
            JOIN sys.tables AS t ON t.object_id = i.object_id
            WHERE i.name LIKE 'IX[_]%' AND t.is_ms_shipped = 0;
            """);

        Assert.Equal(12, count);
    }

    private Task<IReadOnlyList<string>> KeyColumnsOf(string index) =>
        fixture.QueryAsync<string>("""
            SELECT c.name
            FROM sys.indexes AS i
            JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
            JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
            WHERE i.name = @index AND ic.is_included_column = 0
            ORDER BY ic.key_ordinal;
            """, new { index });

    private Task<IReadOnlyList<string>> IncludedColumnsOf(string index) =>
        fixture.QueryAsync<string>("""
            SELECT c.name
            FROM sys.indexes AS i
            JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
            JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
            WHERE i.name = @index AND ic.is_included_column = 1;
            """, new { index });
}
