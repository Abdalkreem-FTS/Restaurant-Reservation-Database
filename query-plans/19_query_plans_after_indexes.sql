-- 19_query_plans_after_indexes.sql
-- Query plans AFTER indexing. Run 18_indexes.sql first, then re-check the
-- same five queries (3, 5, 8, 9, 10) exactly as in 17.

SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE 'ix_%'
ORDER BY tablename, indexname;