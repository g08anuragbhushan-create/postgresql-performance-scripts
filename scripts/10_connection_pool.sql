-- ============================================================================
-- 10 — Connection pool saturation & connection overhead
-- Symptom:  'too many clients' errors; per-request connections; memory thrash
--           from too many backends.
-- Fix:      PgBouncer (transaction pooling); lower max_connections; reuse
--           connections in the app.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Connection usage vs the limit
SELECT count(*) AS backend_count FROM pg_stat_activity;
SELECT setting AS max_connections FROM pg_settings WHERE name='max_connections';

-- Connections by state and user
SELECT usename, state, count(*) FROM pg_stat_activity GROUP BY 1,2 ORDER BY 3 DESC;

-- Per-database connection churn since reset
SELECT datname, xact_commit, xact_rollback, blks_read, blks_hit, temp_files
FROM pg_stat_database
ORDER BY xact_commit DESC;
