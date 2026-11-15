# postgresql-performance-scripts

Diagnostic SQL for the **20 most common PostgreSQL performance problems**. Each script in `scripts/` is self-contained: a header block explains the symptom → diagnosis → fix, followed by read-only diagnostic queries.

Companion to the **PostgreSQL Performance Handbook** (Google Doc), the **Problems & Fixes** sheet, the **Notion** library, and **Linear** improvement issues.

## Scripts

| # | Problem | Script |
|---|---------|--------|
| 1 | Missing Indexes | `scripts/01_missing_indexes.sql` |
| 2 | Unused / Duplicate Indexes | `scripts/02_unused_indexes.sql` |
| 3 | Table & Index Bloat | `scripts/03_bloat.sql` |
| 4 | Autovacuum Falling Behind | `scripts/04_autovacuum.sql` |
| 5 | Stale Statistics | `scripts/05_stale_statistics.sql` |
| 6 | Bad Query Plans | `scripts/06_bad_query_plans.sql` |
| 7 | Lock Contention & Blocking | `scripts/07_lock_contention.sql` |
| 8 | Deadlocks | `scripts/08_deadlocks.sql` |
| 9 | Idle-in-Transaction Sessions | `scripts/09_idle_in_transaction.sql` |
| 10 | Connection Pool Saturation | `scripts/10_connection_pool.sql` |
| 11 | work_mem Too Low (Disk Spills) | `scripts/11_work_mem_spills.sql` |
| 12 | shared_buffers Misconfigured | `scripts/12_shared_buffers.sql` |
| 13 | effective_cache_size Misconfigured | `scripts/13_effective_cache_size.sql` |
| 14 | Checkpoint & WAL I/O | `scripts/14_checkpoint_wal.sql` |
| 15 | Parse Overhead (No Prepared Statements) | `scripts/15_parse_overhead.sql` |
| 16 | N+1 Query Pattern | `scripts/16_nplus1.sql` |
| 17 | SELECT * / OFFSET Pagination | `scripts/17_select_star_offset.sql` |
| 18 | Cartesian Joins / Missing WHERE | `scripts/18_cartesian_joins.sql` |
| 19 | Replication Lag | `scripts/19_replication_lag.sql` |
| 20 | Missing Monitoring | `scripts/20_monitoring.sql` |

## Usage

All scripts are **read-only** and safe to run on production.

```bash
psql -d mydb -f scripts/01_missing_indexes.sql
```

Fix actions are described in each file's header comments; apply them in a maintenance window.

## License

MIT
