using Dapper;
using Microsoft.Data.SqlClient;

namespace RestaurantDb.IntegrationTests.Infrastructure;

public static class Db
{
    extension(SqlServerFixture fixture)
    {
        public async Task<IReadOnlyList<T>> QueryAsync<T>(string sql, object? parameters = null)
        {
            await using var connection = new SqlConnection(fixture.ConnectionString);
            
            return (await connection.QueryAsync<T>(sql, parameters, commandTimeout: 120)).AsList();
        }

        public async Task<IReadOnlyList<dynamic>> QueryRowsAsync(string sql, object? parameters = null)
        {
            await using var connection = new SqlConnection(fixture.ConnectionString);
            
            return (await connection.QueryAsync(sql, parameters, commandTimeout: 120)).AsList();
        }

        public async Task<T?> ScalarAsync<T>(string sql, object? parameters = null)
        {
            await using var connection = new SqlConnection(fixture.ConnectionString);
            
            return await connection.ExecuteScalarAsync<T>(sql, parameters);
        }
    }
}
