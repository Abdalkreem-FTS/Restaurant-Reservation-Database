-- ============================================================================
--  Write ANY query here, then run the SandboxTests.Sandbox_RunsWhateverIsInSandboxSql
--  test. The result is printed to the test output.
--
--  * It runs inside a transaction that is ROLLED BACK, so INSERT / UPDATE / DELETE
--    experiments are completely safe and never touch the seeded data.
-- ============================================================================

-- Example: the five restaurants with the highest revenue.
SELECT TOP 5
       r.RestaurantId,
       r.[Name]                                AS RestaurantName,
       dbo.fn_CalculateRevenue(r.RestaurantId) AS Revenue
FROM Restaurants AS r
ORDER BY Revenue DESC;
