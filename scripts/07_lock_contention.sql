-- ============================================================================
-- 07 — Lock contention & blocking
-- Symptom:  queries pile up waiting on locks; latency spikes under concurrency.
-- Fix:      lock_timeout; short transactions; SELECT ... FOR UPDATE SKIP LOCKED;
--           index foreign keys to avoid full-table locks on cascades.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Blocked sessions and who is blocking them
SELECT now() - blocked.query_start AS wait_time,
       blocked.pid                   AS blocked_pid,
       blocked.query                 AS blocked_query,
       blocking.pid                  AS blocking_pid,
       blocking.query                AS blocking_query,
       l.locktype, l.mode, l.relation::regclass AS locked_relation
FROM pg_stat_activity blocked
JOIN pg_locks bl ON bl.pid = blocked.pid AND NOT bl.granted
JOIN pg_locks l  ON l.locktype = bl.locktype
                AND l.database IS NOT DISTINCT FROM bl.database
                AND l.relation IS NOT DISTINCT FROM bl.relation
                AND l.granted
JOIN pg_stat_activity blocking ON blocking.pid = l.pid
WHERE blocked.pid <> blocking.pid;

-- Heavyweight locks that are currently ungranted
SELECT locktype, relation::regclass AS relation, mode, granted, pid
FROM pg_locks
WHERE NOT granted;
