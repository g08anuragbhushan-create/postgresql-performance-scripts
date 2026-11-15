-- ============================================================================
-- 03 — Table & index bloat (dead tuples)
-- Symptom:  tables/indexes grow physically even though logical row count is
--           stable; scans read more pages; cache efficiency drops.
-- Fix:      VACUUM (VERBOSE, ANALYZE); tune autovacuum; REINDEX CONCURRENTLY;
--           pg_repack for heavy-churn tables.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Dead vs live tuples (quick picture)
SELECT relname, n_live_tup, n_dead_tup,
       round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 1) AS dead_pct,
       last_vacuum, last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Precise per-table bloat (install extension first, once)
-- CREATE EXTENSION IF NOT EXISTS pgstattuple;
-- SELECT * FROM pgstattuple('schema.table_name');   -- dead_tuple_percent is the key
