# pg_cron (Job scheduler)

[Repository](https://github.com/citusdata/pg_cron)

pg_cron is a simple cron-based job scheduler for PostgreSQL (10 or higher) that runs inside the database as an extension.

## Installation

### Alpine

- `sudo apk add postgresql-pg_cron`
- Add `pg_cron` to `shared_preload_libraries`
- Add `cron.database_name = postgres` to settings
- `sudo rc-service postgresql restart`

## Usage

Create the extension in the postgres database - jobs can run in multiple databases but the extension only needs installing in the one defined in settings.

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron
```

This creates the `cron` schema containing 2 tables:

- `cron.job` - list of jobs
- `cron.job_run_details` - execution history

Managing jobs is done via functions:

- `cron.schedule(schedule, command)` - create a nameless job (numeric id is used) in the pg_cron database as the executing user
- `cron.schedule(name, schedule, command)` - creates a job in the pg_cron database as the executing user
- `cron.schedule_in_database(name, schedule, command, database, username, enabled)` - create a job in the specified database, running as the specified user (v1.4.0+ - since 2021)
- `cron.unschedule(id or name)` - remove a job (history is retained)
- `cron.alter_job(id, schedule, command, database, username, enabled)` exists, but scheduling a job with the same name, db and user as one that exists updates the command and status.

### Permissions

The tables implement row-level security - non-superusers can only see their own jobs.

Granting `USAGE` on the `cron` schema allows creation and management of personal jobs. `EXECUTE` needs to be revoked to make this access read-only. To bypass the RLS a view needs to be created owned by a superuser and `SELECT` granted to that to allow viewing all rows. A function with a security definer can also be used. Both of these grant access to view all jobs and commands, so should be restricted to users that need them, or filter out sensitive jobs/commands.

### Example job

```sql
SELECT cron.schedule_in_database(
  'sample',
  '*/5 * * * *',
  $$
-- multi-line SQL statement quoted with $$
SELECT version()
$$,
  'dbname',
  'username',
  true
)
```

Jobs only run when the engine is active, so it doesn't run reliably on serverless clusters that scale to zero.

Jobs can execute any procedural language, but cannot run external processes, so cannot be used for backups via `pg_dump` etc.