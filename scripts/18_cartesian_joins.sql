-- ============================================================================
-- 18 — Cartesian joins / missing WHERE clauses
-- Symptom:  JOIN without ON/WHERE cross-multiplies tables, producing enormous
--           intermediate results that are filtered too late.
-- Fix:      add the join condition / predicate; add FKs so mistakes surface.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Foreign-key catalog gaps can hide accidental cartesian joins
SELECT conrelid::regclass AS table_name, conname
FROM pg_constraint WHERE contype='f'
ORDER BY 1;

-- Detect a cartesian join in a specific query via the plan:
-- EXPLAIN (ANALYZE, BUFFERS) <your query>;
-- Look for a Nested Loop node with no join filter and astronomic row counts.

-- Enable statement logging to catch them in production:
-- log_min_duration_statement = 1000   (ms; then inspect slow queries)
