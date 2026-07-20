using Microsoft.Data.SqlClient;

namespace RestaurantDb.IntegrationTests.Infrastructure;

public abstract class TransactionalTest(SqlServerFixture fixture) : IAsyncLifetime
{
    protected SqlConnection Connection = null!;
    protected SqlTransaction Transaction = null!;

    public async Task InitializeAsync()
    {
        Connection = new SqlConnection(fixture.ConnectionString);
        await Connection.OpenAsync();
        Transaction = (SqlTransaction)await Connection.BeginTransactionAsync();
    }

    public async Task DisposeAsync()
    {
        await Transaction.RollbackAsync();
        await Transaction.DisposeAsync();
        await Connection.DisposeAsync();
    }
}
