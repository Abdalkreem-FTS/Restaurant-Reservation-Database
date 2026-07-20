namespace RestaurantDb.IntegrationTests.Infrastructure;

/// <summary>
/// Ensures one container shared for all tests (sequentially not in parallel).
/// </summary>
[CollectionDefinition(SqlServerCollectionName)]
public sealed class DatabaseCollection : ICollectionFixture<SqlServerFixture>
{
    public const string SqlServerCollectionName = "sqlserver";
}
