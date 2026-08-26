# pg_stat_statements

Provides a means for tracking planning and execution statistics of all SQL statements executed by a server.

## Installation

### Alpine

Included as part of `postgresql-contrib`

### Neon

Included and preloaded by default. Settings are the defaults and not user-editable:

```ini
max = 5000
save = on
track = top
track_planning = off
track_utility = on
```

### Settings

```sh
shared_preload_libraries = 'pg_stat_statements' # requires restart
pg_stat_statements.max = 10000 # default is 5000
pg_stat_statements.track = all # default only tracks top statement so nested queries are blamed on parent
pg_stat_statements.track_planning = on # default is off, planner times show as zero
```

## Usage

- Install extension (requires superuser)
    ```sql
    CREATE EXTENSION pg_stat_statements; --requires superuser
    ```
- Creates the view `pg_stat_statements`, which requires membership of role `pg_read_all_stats` to see detail in
- To reset the stats (after a big change or to monitor something specific):
    ```sql
    SELECT pg_stat_statements_reset();
    ```

- To find problem queries[^1]: <!-- TODO: test and expand -->
    ```sql
    SELECT
        substring(query, 1, 60) AS query_fragment,
        calls,
        round(total_exec_time::numeric / 1000, 1) AS total_sec,
        round(mean_exec_time::numeric, 3) AS mean_ms,
        round(total_plan_time::numeric / 1000, 1) AS plan_sec,
        round(rows::numeric / nullif(calls, 0), 1) AS avg_rows,
        round(100.0 * shared_blks_hit /
            nullif(shared_blks_hit + shared_blks_read, 0), 1) AS hit_pct
    FROM pg_stat_statements
    WHERE query NOT ILIKE '%pg_stat_statements%'
    ORDER BY total_exec_time DESC
    LIMIT 10;
    ```

### What to look for

<!-- TODO: once I have some significant usage data -->






[^1]: [What pg_stat_statements Actually Tells You About Your Queries](https://www.tigerdata.com/blog/what-pg_stat_statements-actually-tells-you-about-your-queries)