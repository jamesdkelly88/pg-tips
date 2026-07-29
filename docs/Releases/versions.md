# Versions

PostgreSQL releases a major version once a year (usually in September). Major versions are supported for 5 years after release, with minor versions released every quarter (Nov, Feb, May, Aug) to apply security fixes[^1].

Since version `10`, the major version has been a single number. Before this, it was 2 numbers e.g. `9.6`.

To check the current version on your system:

```sql
SELECT version();
```

## Version Table
[^1]: [endoflife.date](https://endoflife.date/postgresql)

{{ read_csv('data/versions.csv') }}