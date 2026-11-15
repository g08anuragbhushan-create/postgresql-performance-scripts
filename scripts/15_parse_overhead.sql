-- ============================================================================
-- 15 — High CPU from parsing (no prepared statements)
-- Symptom:  re-parsing/re-planning raw SQL on every call burns CPU at high QPS.
-- Fix:      server-side prepared statements / extended protocol binding;
--           enable pg_stat_statements (see 20) to see plan vs exec time.
-- Requires: pg_stat_statements extension loaded (shared_preload_libraries).
-- ============================================================================

SELECT queryid, calls,
       round(total_plan_time::numeric / NULLIF(calls,0), 2) AS avg_plan_ms,
       round(total_exec_time::numeric / NULLIF(calls,0), 2) AS avg_exec_ms,
       left(query, 80) AS query
FROM pg_stat_statements
ORDER BY total_plan_time DESC
LIMIT 20;

-- Are prepared statements actually being used?
SELECT name, statement, prepare_time, generic_plans, custom_plans
FROM pg_prepared_statements;
