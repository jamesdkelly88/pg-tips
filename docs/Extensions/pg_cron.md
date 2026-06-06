# pg_cron (Job scheduler)

[Repository](https://github.com/citusdata/pg_cron)

pg_cron is a simple cron-based job scheduler for PostgreSQL (10 or higher) that runs inside the database as an extension.

## Installation

### Alpine

- `sudo apk add postgresql-pg_cron`
- Add `pg_cron` to `shared_preload_libraries`
- `sudo rc-service postgresql restart`

## Usage

