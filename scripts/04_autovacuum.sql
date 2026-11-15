-- ============================================================================
-- 04 — Autovacuum falling behind & transaction-ID wraparound risk
-- Symptom:  bloat accumulates; autovacuum can't keep up; long transactions
--           block vacuum; worst case = wraparound shutdown.
-- Fix:      idle_in_transaction_session_timeout; raise autovacuum_vacuum_cost_
--           limit; more workers; lower per-table thresholds; watch age(relfrozenxid).
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Long-running / idle-in-transaction sessions that block vacuum
SELECT pid, now() - xact_start AS xact_age, state, query
FROM pg_stat_activity
WHERE state <> 'idle' AND xact_start < now() - interval '10 minutes'
ORDER BY xact_start;

-- Tables vacuum is struggling with
SELECT relname, n_dead_tup, last_autovacuum, last_autoanalyze,
       autovacuum_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Wraparound health (run per table of interest; high age = vacuum urgently)
SELECT relname, age(relfrozenxid) AS xid_age
FROM pg_class
WHERE relkind IN ('r','m','t')
ORDER BY age(relfrozenxid) DESC
LIMIT 20;
