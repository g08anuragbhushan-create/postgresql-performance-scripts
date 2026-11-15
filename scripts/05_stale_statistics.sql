-- ============================================================================
-- 05 — Stale or missing table statistics
-- Symptom:  planner's row estimates are wrong (EXPLAIN rows vs actual rows far
--           apart) after bulk loads/deletes -> bad join order and plans.
-- Fix:      ANALYZE hot tables; raise default_statistics_target; add extended
--           statistics for correlated columns; tune analyze thresholds.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Tables changed a lot since the last ANALYZE
SELECT relname, last_analyze, last_autoanalyze, n_mod_since_analyze,
       n_live_tup
FROM pg_stat_user_tables
WHERE n_mod_since_analyze > 100000
ORDER BY n_mod_since_analyze DESC;

-- Current statistics target (raise for skewed columns)
SELECT setting AS default_statistics_target
FROM pg_settings WHERE name = 'default_statistics_target';

-- Correlated-column fix (run when you see mis-estimates on multi-col filters):
-- CREATE STATISTICS s_mcv (mcv) ON col_a, col_b FROM my_table;
