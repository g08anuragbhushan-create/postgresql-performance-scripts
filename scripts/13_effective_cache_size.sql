-- ============================================================================
-- 13 — effective_cache_size misconfigured
-- Symptom:  planner over-prefers seq scans because it under-estimates available
--           cache (shared_buffers + OS cache).
-- Fix:      set effective_cache_size ~50-75% of total RAM.
-- Safe:     read-only diagnostics.
-- ============================================================================

SELECT name, setting, unit FROM pg_settings WHERE name = 'effective_cache_size';

-- Test whether an index scan would actually be faster for a suspect query:
-- BEGIN;
--   SET LOCAL enable_seqscan = off;
--   EXPLAIN (ANALYZE, BUFFERS) <your query>;
-- ROLLBACK;
-- If much faster: consider raising effective_cache_size (or the index is the
-- right path and random_page_cost is simply too high).
