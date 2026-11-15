-- ============================================================================
-- 02 — Unused, duplicate & redundant indexes
-- Symptom:  every extra index adds write overhead + cache pressure; unused or
--           overlapping indexes silently slow the database.
-- Fix:      DROP INDEX CONCURRENTLY (after confirming idx_scan stays 0), merge
--           indexes sharing the same leading column.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Never-scanned, non-unique indexes, biggest first
SELECT schemaname,
       s.relname                      AS table_name,
       s.indexrelname                 AS index_name,
       s.idx_scan,
       s.idx_tup_read,
       pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size
FROM pg_stat_user_indexes s
JOIN pg_index i ON s.indexrelid = i.indexrelid
WHERE i.indisunique = false
ORDER BY s.idx_scan ASC, pg_relation_size(s.indexrelid) DESC
LIMIT 30;

-- Candidate duplicates: same table, same leading column
WITH ix AS (
  SELECT schemaname, relname, indexrelname,
         (SELECT a.attname FROM pg_attribute a
           JOIN unnest(i.indkey::int[]) WITH ORDINALITY k(attnum, ord)
             ON a.attnum = k.attnum AND a.attrelid = i.indrelid
          WHERE k.ord = 1 LIMIT 1) AS leading_col
  FROM pg_stat_user_indexes s
  JOIN pg_index i ON s.indexrelid = i.indexrelid
)
SELECT * FROM ix ORDER BY schemaname, relname, leading_col;
