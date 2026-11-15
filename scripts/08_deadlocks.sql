-- ============================================================================
-- 08 — Deadlocks
-- Symptom:  two transactions wait on each other; PostgreSQL aborts one with
--           SQLSTATE 40P01 and the app errors or retries.
-- Fix:      consistent lock order; smaller transactions; app-level retry on 40P01;
--           enable log_lock_waits to capture the statements.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Deadlock counter for this database
SELECT datname, deadlocks FROM pg_stat_database
WHERE datname = current_database();

-- Recommended logging settings (add to postgresql.conf, then reload)
-- log_lock_waits = on
-- deadlock_timeout = 1s        (default)

-- Sessions holding locks the longest (likely participants)
SELECT pid, now() - xact_start AS xact_age, state, query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
ORDER BY xact_start
LIMIT 20;
