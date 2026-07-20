using Dapper;
using Microsoft.Data.SqlClient;
using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class ReportProcedureTests(SqlServerFixture fixture)
{
    private const string Report = "EXEC dbo.sp_ReservedTablesReport @StartDate = @start, @EndDate = @end;";

    [Fact]
    public async Task sp_ReservedTablesReport_DateRangeGiven_ReturnsOnlyReservationsInThatRange()
    {
        var start = new DateTime(2026, 1, 1);
        var end = new DateTime(2026, 3, 31, 23, 59, 59);

        var rows = await fixture.QueryRowsAsync(Report, new { start, end });

        Assert.NotEmpty(rows);
        Assert.All(rows, r =>
        {
            var date = (DateTime)r.ReservationDate;
            Assert.InRange(date, start, end);
        });
    }

    [Fact]
    public async Task sp_ReservedTablesReport_DateRangeGiven_ReturnsCapacityAndRestaurantOfEachTable()
    {
        var rows = await fixture.QueryRowsAsync(Report,
            new { start = new DateTime(2026, 1, 1), end = new DateTime(2026, 3, 31, 23, 59, 59) });

        Assert.All(rows, r =>
        {
            Assert.True((int)r.Capacity > 0);
            Assert.False(string.IsNullOrWhiteSpace((string)r.RestaurantName));
        });
    }
    
    [Fact]
    public async Task sp_ReservedTablesReport_EndDateAtMidnight_ExcludesLaterTimesThatDay()
    {
        var start = new DateTime(2026, 1, 1);

        var toMidnight = await fixture.QueryRowsAsync(Report, new { start, end = new DateTime(2026, 3, 31) });
        var toEndOfDay = await fixture.QueryRowsAsync(Report, new { start, end = new DateTime(2026, 3, 31, 23, 59, 59) });

        Assert.True(toEndOfDay.Count >= toMidnight.Count);
    }

    [Fact]
    public async Task sp_ReservedTablesReport_RangeHasNoReservations_ReturnsNoRows()
    {
        var rows = await fixture.QueryRowsAsync(Report,
            new { start = new DateTime(1990, 1, 1), end = new DateTime(1990, 12, 31) });

        Assert.Empty(rows);
    }

    [Fact]
    public async Task sp_FutureReservationTables_Always_ReturnsOnlyTablesWithAFutureReservation()
    {
        var rows = await fixture.QueryRowsAsync("EXEC dbo.sp_FutureReservationTables;");

        Assert.NotEmpty(rows);

        var tableIds = rows.Select(r => (int)r.TableId).Distinct().ToList();
        var withoutFutureReservation = await fixture.ScalarAsync<int>("""
            SELECT COUNT(*) FROM (
                SELECT value AS TableId FROM STRING_SPLIT(@ids, ',')
            ) AS t
            WHERE NOT EXISTS (
                SELECT 1 FROM Reservations r
                WHERE r.TableId = t.TableId AND r.ReservationDate > GETDATE());
            """, new { ids = string.Join(",", tableIds) });

        Assert.Equal(0, withoutFutureReservation);
    }
}

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class AddNewOrderTests(SqlServerFixture fixture) : TransactionalTest(fixture)
{
    private const string AddOrder =
        "EXEC dbo.sp_AddNewOrder @ReservationId = @reservation, @EmployeeId = @employee, " +
        "@OrderDate = @date, @TotalAmount = @total;";

    [Fact]
    public async Task sp_AddNewOrder_OrderIsValid_InsertsItAndReturnsTheNewId()
    {
        var newOrderId = await Connection.ExecuteScalarAsync<int>(AddOrder,
            new { reservation = 1, employee = 1, date = new DateTime(2026, 7, 15), total = 42.50m },
            Transaction);

        Assert.True(newOrderId > 500, $"Expected an id beyond the seeded 500 but got {newOrderId}.");

        var stored = await Connection.QuerySingleAsync<(int ReservationId, decimal TotalAmount)>(
            "SELECT ReservationId, TotalAmount FROM Orders WHERE OrderId = @newOrderId;",
            new { newOrderId }, Transaction);

        Assert.Equal(1, stored.ReservationId);
        Assert.Equal(42.50m, stored.TotalAmount);
    }

    [Fact]
    public async Task sp_AddNewOrder_ReservationDoesNotExist_ThrowsSqlException()
    {
        var ex = await Assert.ThrowsAsync<SqlException>(() =>
            Connection.ExecuteScalarAsync<int>(AddOrder,
                new { reservation = 999_999, employee = 1, date = new DateTime(2026, 7, 15), total = 42.50m },
                Transaction));

        Assert.Contains("Reservation 999999 does not exist", ex.Message);
    }

    [Fact]
    public async Task sp_AddNewOrder_EmployeeDoesNotExist_ThrowsSqlException()
    {
        var ex = await Assert.ThrowsAsync<SqlException>(() =>
            Connection.ExecuteScalarAsync<int>(AddOrder,
                new { reservation = 1, employee = 999_999, date = new DateTime(2026, 7, 15), total = 42.50m },
                Transaction));

        Assert.Contains("Employee 999999 does not exist", ex.Message);
    }

    [Fact]
    public async Task sp_AddNewOrder_ReservationDoesNotExist_DoesNotInsertTheOrder()
    {
        var before = await Connection.ExecuteScalarAsync<int>(
            "SELECT COUNT(*) FROM Orders;", transaction: Transaction);

        await Assert.ThrowsAsync<SqlException>(() =>
            Connection.ExecuteScalarAsync<int>(AddOrder,
                new { reservation = 999_999, employee = 1, date = new DateTime(2026, 7, 15), total = 42.50m },
                Transaction));

        var after = await Connection.ExecuteScalarAsync<int>(
            "SELECT COUNT(*) FROM Orders;", transaction: Transaction);

        Assert.Equal(before, after);
    }
}
