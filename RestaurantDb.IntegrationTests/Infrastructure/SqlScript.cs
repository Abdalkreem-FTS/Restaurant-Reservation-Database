namespace RestaurantDb.IntegrationTests.Infrastructure;

public static class SqlScript
{
    private static readonly string SqlRoot = Path.Combine(AppContext.BaseDirectory, "sql");

    public static Task<string> RootAsync(string fileName) =>
        File.ReadAllTextAsync(Path.Combine(SqlRoot, fileName));

    public static Task<string> QueryAsync(string fileName) =>
        File.ReadAllTextAsync(Path.Combine(SqlRoot, "queries", fileName));

    public static Task<string> QueryPlanAsync(string fileName) =>
        File.ReadAllTextAsync(Path.Combine(SqlRoot, "query-plans", fileName));
}
