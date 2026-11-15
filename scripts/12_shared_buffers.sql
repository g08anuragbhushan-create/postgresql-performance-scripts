-- ============================================================================
-- 12 — shared_buffers misconfigured
-- Symptom:  low cache hit ratio (frequent physical reads) or, conversely,
--           double-buffering + heavy checkpoints from an oversized cache.
-- Fix:      ~25% of RAM, capped ~8-10GB; rely on OS page cache for the rest.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Current setting vs system memory hint
SELECT name, setting, unit FROM pg_settings WHERE name = 'shared_buffers';

-- Buffer read activity since reset
SELECT buffers_checkpoint, buffers_backend, buffers_clean, buffers_alloc
FROM pg_stat_bgwriter;

-- Approx cache hit ratio = 1 - buffers_backend / (checkpoint+clean+backend)
SELECT round(100.0 * (1 - buffers_backend::numeric /
       NULLIF(buffers_checkpoint + buffers_clean + buffers_backend, 0)), 1)
       AS shared_cache_hit_pct
FROM pg_stat_bgwriter;
