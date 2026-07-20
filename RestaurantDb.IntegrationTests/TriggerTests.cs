using Dapper;
using Microsoft.Data.SqlClient;
using RestaurantDb.IntegrationTests.Infrastructure;

namespace RestaurantDb.IntegrationTests;

[Collection(DatabaseCollection.SqlServerCollectionName)]
public class TriggerTests(SqlServerFixture fixture) : TransactionalTest(fixture)
{
    private const string InsertReservation = """
        INSERT INTO Reservations (CustomerId, RestaurantId, TableId, ReservationDate, PartySize)
        VALUES (@customer, @restaurant, @table, @date, @party);
        """;

    private Task<int> AuditRowCount() =>
        Connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM AuditLog;", transaction: Transaction);

    [Fact]
    public async Task trg_AuditReservation_ReservationInserted_WritesAnAuditRow()
    {
        var before = await AuditRowCount();

        await Connection.ExecuteAsync(InsertReservation,
            new { customer = 1, restaurant = 1, table = 1, date = new DateTime(2027, 1, 1, 19, 0, 0), party = 2 },
            Transaction);

        Assert.Equal(before + 1, await AuditRowCount());
    }

    [Fact]
    public async Task trg_AuditReservation_ReservationInserted_CapturesTheReservationsDetails()
    {
        var date = new DateTime(2027, 2, 3, 20, 30, 0);

        await Connection.ExecuteAsync(InsertReservation,
            new { customer = 5, restaurant = 3, table = 3, date, party = 2 }, Transaction);

        var audit = await Connection.QuerySingleAsync<(int RestaurantId, int TableId, DateTime ReservationDate, DateTime ChangeDate)>(
            "SELECT TOP 1 RestaurantId, TableId, ReservationDate, ChangeDate FROM AuditLog ORDER BY AuditId DESC;",
            transaction: Transaction);

        Assert.Equal(3, audit.RestaurantId);
        Assert.Equal(3, audit.TableId);
        Assert.Equal(date, audit.ReservationDate);
        Assert.NotEqual(default, audit.ChangeDate);
    }
    
    [Fact]
    public async Task trg_AuditReservation_MultiRowInsert_WritesOneAuditRowPerReservation()
    {
        var before = await AuditRowCount();

        await Connection.ExecuteAsync("""
            INSERT INTO Reservations (CustomerId, RestaurantId, TableId, ReservationDate, PartySize)
            VALUES (1, 1, 1, '2027-03-01T19:00:00', 2),
                   (2, 1, 1, '2027-03-02T19:00:00', 2),
                   (3, 1, 1, '2027-03-03T19:00:00', 2);
            """, transaction: Transaction);

        Assert.Equal(before + 3, await AuditRowCount());
    }

    [Fact]
    public async Task trg_AuditReservation_TransactionRolledBack_RollsBackTheAuditRowToo()
    {
        var before = await AuditRowCount();

        await Connection.ExecuteAsync(InsertReservation,
            new { customer = 1, restaurant = 1, table = 1, date = new DateTime(2027, 4, 1, 19, 0, 0), party = 2 },
            Transaction);
        Assert.Equal(before + 1, await AuditRowCount());

        await Transaction.RollbackAsync();

        Transaction = (SqlTransaction)await Connection.BeginTransactionAsync();
        Assert.Equal(before, await AuditRowCount());
    }
}
