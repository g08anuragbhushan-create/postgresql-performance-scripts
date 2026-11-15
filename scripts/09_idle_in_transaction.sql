-- ============================================================================
-- 09 — Idle-in-transaction sessions
-- Symptom:  sessions hold an open transaction while doing nothing -> hold locks,
--           block VACUUM, and burn connection slots.
-- Fix:      idle_in_transaction_session_timeout = '5min'; commit/rollback quickly;
--           fix app code; run a pooler (PgBouncer).
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Idle-in-transaction sessions, oldest first
SELECT pid, usename, now() - state_change AS idle_for, query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY state_change;

-- All session states (distribution)
SELECT state, count(*) FROM pg_stat_activity GROUP BY state;
