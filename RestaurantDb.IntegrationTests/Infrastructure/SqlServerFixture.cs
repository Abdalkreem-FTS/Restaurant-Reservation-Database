using Microsoft.Data.SqlClient;
using Testcontainers.MsSql;

namespace RestaurantDb.IntegrationTests.Infrastructure;

/// <summary>
/// Starts one SQL Server container for the whole test run and builds the database from the
/// repository's own scripts: 01 (schema), 02 (seed), then the views/functions/procedures/
/// trigger/indexes.
/// </summary>
public sealed class SqlServerFixture : IAsyncLifetime
{
    private const string DatabaseName = "RestaurantReservationDB";

    private readonly MsSqlContainer _container = new MsSqlBuilder("mcr.microsoft.com/mssql/server:2022-latest").Build();

    public string ConnectionString { get; private set; } = string.Empty;

    public async Task InitializeAsync()
    {
        await _container.StartAsync();
        
        await ExecuteOnMasterAsync($"CREATE DATABASE [{DatabaseName}];");

        ConnectionString = new SqlConnectionStringBuilder(_container.GetConnectionString())
        {
            InitialCatalog = DatabaseName
        }.ConnectionString;

        await ExecuteAsync(await SqlScript.RootAsync("01_create_tables.sql"));
        await ExecuteAsync(await SqlScript.RootAsync("02_seed_data.sql"));

        await DeployObjectsAsync(); // views, functions, stored procedures
    }
    
    private async Task DeployObjectsAsync()
    {
        string[] objectFiles =
        [
            "06_view_reservations_report.sql",
            "07_view_employee_details.sql",
            "11_fn_calculate_revenue.sql",
            "12_fn_calculate_employee_salary.sql",
            "13_sp_reserved_tables_report.sql",
            "14_sp_add_new_order.sql",
            "15_sp_future_reservation_tables.sql",
            "16_trg_audit_reservation.sql"
        ];
        
        foreach (var file in objectFiles)
        {
            await ExecuteAsync(await SqlScript.QueryAsync(file));
        }
        
        await ExecuteAsync(await SqlScript.QueryPlanAsync("18_indexes.sql"));
    }

    public async Task ExecuteAsync(string sql)
    {
        await using var connection = new SqlConnection(ConnectionString);
        
        await connection.OpenAsync();
        
        await using var command = new SqlCommand(sql, connection);
        command.CommandTimeout = 120;
        
        await command.ExecuteNonQueryAsync();
    }

    private async Task ExecuteOnMasterAsync(string sql)
    {
        await using var connection = new SqlConnection(_container.GetConnectionString());
        
        await connection.OpenAsync();
        
        await using var command = new SqlCommand(sql, connection);
        
        await command.ExecuteNonQueryAsync();
    }

    public async Task DisposeAsync() => await _container.DisposeAsync();
}
