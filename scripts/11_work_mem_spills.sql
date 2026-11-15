-- ============================================================================
-- 11 — work_mem too low (sorts & hash spills to disk)
-- Symptom:  EXPLAIN shows 'Sort Method: external merge Disk'; temp files climb;
--           sorts/hash joins are orders of magnitude slower.
-- Fix:      raise work_mem (budget = work_mem x concurrent queries); use
--           hash_mem_multiplier (PG15+); reduce data sorted.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Temp file / spill volume since reset
SELECT datname, temp_files, temp_bytes, pg_size_pretty(temp_bytes) AS temp_size
FROM pg_stat_database
WHERE temp_files > 0
ORDER BY temp_bytes DESC;

-- Current memory settings
SELECT name, setting, unit FROM pg_settings
WHERE name IN ('work_mem','hash_mem_multiplier','maintenance_work_mem');

-- For a specific query, watch for spills:
-- EXPLAIN (ANALYZE, BUFFERS) <your query>;   -- 'external merge Disk' lines
