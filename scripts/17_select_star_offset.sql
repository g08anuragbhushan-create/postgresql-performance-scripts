-- ============================================================================
-- 17 — SELECT * and deep OFFSET pagination
-- Symptom:  huge row width (TOASTed columns) and OFFSET scans that read then
--           discard rows -> wasted I/O, slow pagination.
-- Fix:      select only needed columns; keyset pagination (WHERE id > :last
--           ORDER BY id LIMIT n); add a covering index.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Tables storing lots of TOASTed (out-of-line) data
SELECT c.relname, c.reltoastrelid::regclass AS toast_table,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
WHERE c.reltoastrelid <> 0
ORDER BY pg_total_relation_size(c.oid) DESC
LIMIT 20;

-- Wide tables (avg row width) = SELECT * is expensive here
SELECT relname, n_live_tup,
       round(pg_relation_size(relid)::numeric / NULLIF(n_live_tup,0), 1) AS bytes_per_row
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY bytes_per_row DESC
LIMIT 20;
