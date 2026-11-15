-- ============================================================================
-- 14 — Checkpoint & WAL tuning (I/O spikes)
-- Symptom:  periodic I/O spikes; frequent demand checkpoints; commits gated by
--           slow fsync.
-- Fix:      max_wal_size ~2-4GB; checkpoint_completion_target=0.9; WAL on fast
--           separate storage; synchronous_commit=off for non-critical only.
-- Safe:     read-only diagnostics.
-- ============================================================================

-- Checkpoint activity since reset
SELECT checkpoints_timed, checkpoints_req, checkpoint_write_time,
       checkpoint_sync_time, buffers_checkpoint
FROM pg_stat_bgwriter;

-- WAL settings
SELECT name, setting, unit FROM pg_settings
WHERE name IN ('max_wal_size','min_wal_size','checkpoint_completion_target',
               'wal_compression','synchronous_commit','full_page_writes');

-- WAL size on disk
SELECT pg_size_pretty(sum(size)) AS total_wal_size
FROM pg_ls_waldir();
