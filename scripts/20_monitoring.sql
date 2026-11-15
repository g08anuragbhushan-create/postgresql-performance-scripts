-- ============================================================================
-- 20 — Missing monitoring & observability
-- Symptom:  problems 1-19 are invisible until they become incidents; no stats,
--           no slow-query log, no dashboards.
-- Fix:      enable pg_stat_statements + auto_explain in shared_preload_libraries;
--           log_min_duration_statement; postgres_exporter -> Prometheus/Grafana.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Is pg_stat_statements loaded?
SHOW shared_preload_libraries;

-- Slow-query log & instrumentation settings
SELECT name, setting, unit FROM pg_settings
WHERE name IN ('log_min_duration_statement','log_lock_waits','log_statement',
               'track_io_timing','track_activities','track_counts',
               'track_functions','shared_preload_libraries');

-- Per-database stats & bloat signal (needs pg_stat_statements for q-level view)
SELECT datname, xact_commit, tup_returned, temp_files, deadlocks, blks_read, blks_hit
FROM pg_stat_database ORDER BY xact_commit DESC;

-- Setup (once, requires restart):
--   ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements,auto_explain';
--   restart, then: CREATE EXTENSION pg_stat_statements;
--   ALTER SYSTEM SET log_min_duration_statement = '250ms';
--   ALTER SYSTEM SET log_lock_waits = on;
