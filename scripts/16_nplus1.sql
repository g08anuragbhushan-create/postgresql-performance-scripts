-- ============================================================================
-- 16 — N+1 query pattern (excessive round trips)
-- Symptom:  app fetches a list then issues one query per row in a loop;
--           thousands of tiny near-identical statements.
-- Fix:      batch (WHERE id = ANY($1)), JOIN, eager-load in the ORM, multi-row
--           VALUES inserts.
-- Requires: pg_stat_statements extension.
-- ============================================================================

-- Many near-identical tiny queries = classic N+1 signature
SELECT left(query, 120) AS query, calls,
       round(total_exec_time::numeric / NULLIF(calls,0), 3) AS avg_exec_ms,
       rows
FROM pg_stat_statements
WHERE calls > 1000 AND rows < 100
ORDER BY calls DESC
LIMIT 30;

-- Round-trip pressure on the database
SELECT datname, xact_commit, tup_returned, tup_fetched
FROM pg_stat_database ORDER BY xact_commit DESC;
