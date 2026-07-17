namespace RestaurantDb.IntegrationTests.Infrastructure;

/// <summary>
/// Loads sandbox.sql from the project's SOURCE directory (not the build output), so an edit is
/// picked up on the next test run. It walks up from the build output folder until it finds the
/// file, which keeps it independent of where in the source tree the tests run from. If the file
/// can't be found (e.g. the assembly is run detached from its source), it returns empty and the
/// test simply reports there is nothing to run.
/// </summary>
public static class Sandbox
{
    private const string FileName = "sandbox.sql";

    public static async Task<string> LoadAsync()
    {
        var path = Locate();
        return path is null ? string.Empty : await File.ReadAllTextAsync(path);
    }

    private static string? Locate()
    {
        for (var dir = new DirectoryInfo(AppContext.BaseDirectory); dir is not null; dir = dir.Parent)
        {
            var candidate = Path.Combine(dir.FullName, FileName);
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        return null;
    }
}
