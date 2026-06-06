# postgresql.conf

This file contains the settings for PostgreSQL


## Usage

All examples use `shared_preload_libraries`

### Get value of a setting (SHOW)

```sql
SHOW shared_preload_libraries;
```

### Get value of a setting (SELECT)

```sql
SELECT setting
FROM pg_settings
WHERE name = 'shared_preload_libraries';
```

### Updating a setting (SET)

```sql
SET shared_preload_libraries = 'pg_stat_statements';
```

### Updating a setting (UPDATE)

```sql
UPDATE pg_settings
SET setting = 'pg_stat_statements'
WHERE name = 'shared_preload_libraries';
```

### Check if setting requires a restart

```sql
SELECT context
FROM pg_settings
WHERE name = 'shared_preload_libraries';
```

- `internal` - cannot be changed
- `postmaster` - requires a restart after editing `postgresql.conf`
- `sighup` - requires sending a `SIGHUP` via `SELECT pg_reload_conf()` - superusers only
- `superuser-backend` - can be `SET` for future sessions but cannot be changed once set for an active session - superusers only
- `backend` - can be `SET` for future sessions but cannot be changed once set for an active session - all users
- `superuser` - can be `SET` - superusers only
- `user` - can be `SET`
