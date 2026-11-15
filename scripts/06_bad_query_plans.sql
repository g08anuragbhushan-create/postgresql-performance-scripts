-- ============================================================================
-- 06 — Bad query plans (wrong join strategy / order)
-- Symptom:  planner picks nested loops over huge tables or seq scans where an
--           index is cheaper, usually from wrong cost parameters.
-- Fix:      random_page_cost=1.1 (SSD); fresh stats; correct indexes; test with
--           SET enable_nestloop=off before rewriting the query.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Current cost settings (the usual culprits)
SELECT name, setting, unit, boot_val
FROM pg_settings
WHERE name IN ('random_page_cost','seq_page_cost','cpu_tuple_cost',
               'cpu_index_tuple_cost','cpu_operator_cost','jit');

-- Largest tables for a sanity check that stats exist
SELECT c.relname, c.reltuples::bigint AS estimated_rows,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS size
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND c.relkind = 'r'
ORDER BY c.reltuples DESC LIMIT 20;

-- Drill into the actual plan:
-- EXPLAIN (ANALYZE, BUFFERS, SETTINGS) <your query>;
