using Dapper;
using RestaurantDb.IntegrationTests.Infrastructure;
using Xunit.Abstractions;

namespace RestaurantDb.IntegrationTests;

/// <summary>
/// A live SQL scratchpad. Write anything into sandbox.sql, run this test, and read the result
/// in the test output. Everything runs inside a rolled-back transaction (via TransactionalTest),
/// so it is safe to experiment with INSERT / UPDATE / DELETE - none of it survives the test, and
/// the seeded data the other tests rely on is never touched.
///
/// The [Trait] lets a CI pipeline exclude it with:  dotnet test --filter "Category!=Sandbox"
/// so a half-written scratch query can never break the real build.
/// </summary>
[Trait("Category", "Sandbox")]
[Collection(DatabaseCollection.Name)]
public class SandboxTests(SqlServerFixture fixture, ITestOutputHelper output) : TransactionalTest(fixture)
{
    [Fact]
    public async Task Sandbox_RunsWhateverIsInSandboxSql()
    {
        var sql = await Sandbox.LoadAsync();

        if (string.IsNullOrWhiteSpace(sql))
        {
            output.WriteLine("sandbox.sql is empty - nothing to run.");
            
            return;
        }
        
        var rows = (await Connection.QueryAsync(sql, transaction: Transaction))
            .Cast<IDictionary<string, object>>()
            .ToList();

        PrintAsTable(rows);
    }

    private void PrintAsTable(List<IDictionary<string, object>> rows)
    {
        if (rows.Count == 0)
        {
            output.WriteLine("(the query returned no rows)");
            return;
        }

        var columns = rows[0].Keys.ToList();
        output.WriteLine(string.Join(" | ", columns));
        output.WriteLine(new string('-', 72));

        foreach (var row in rows)
        {
            output.WriteLine(string.Join(" | ", columns.Select(c => Format(row[c]))));
        }

        output.WriteLine($"({rows.Count} row(s))");
    }

    private static string Format(object? value) => value?.ToString() ?? "NULL";
}
