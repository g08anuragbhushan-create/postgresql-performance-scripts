-- ============================================================================
-- 01 — Missing Indexes (unindexed columns & foreign keys)
-- Symptom:  SELECTs that filter/join/sort on unindexed columns do sequential
--           scans; latency grows linearly as tables grow.
-- Fix:      CREATE INDEX CONCURRENTLY on WHERE/JOIN/ORDER BY columns; index FKs.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Tables doing the most sequential scans
SELECT schemaname, relname, seq_scan, seq_tup_read,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;

-- Foreign keys with no supporting index (join & cascade-delete blockers)
SELECT conrelid::regclass AS table_name,
       conname            AS constraint_name
FROM pg_constraint
WHERE contype = 'f'
  AND NOT EXISTS (
        SELECT 1 FROM pg_index i
        WHERE i.indrelid = conrelid
          AND i.indkey::int[] @> conkey::int[]
      )
ORDER BY 1;

-- Confirm the fix on a specific query:
-- EXPLAIN (ANALYZE, BUFFERS) <your query>;   -- want Index Scan / Bitmap Index Scan
