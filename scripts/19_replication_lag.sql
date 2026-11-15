-- ============================================================================
-- 19 — Replication lag on standby
-- Symptom:  read replicas serve stale data; failover would lose work.
-- Fix:      tune replica queries / max_standby_streaming_delay; use replication
--           slots; balance read load; add replicas.
-- Safe:     read/write diagnostics.
-- ============================================================================

-- On the STANDBY: how far behind is replay?
SELECT now() - pg_last_xact_replay_timestamp() AS replay_lag;

-- On the PRIMARY: per-replica lag and state
SELECT application_name, client_addr, state, sync_state,
       pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS lag_bytes,
       replay_lag
FROM pg_stat_replication;

-- Logical slots can pin WAL: check consumption
SELECT slot_name, slot_type, active,
       pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS restart_lsn_lag
FROM pg_replication_slots;
