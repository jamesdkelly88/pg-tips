# New Features

## 18[^1]
[^1]: [PostgreSQL 18: A Comprehensive Guide to New Features for DBAs and Developers](https://towardsdev.com/postgresql-18-a-comprehensive-guide-to-new-features-for-dbas-and-developers-b355e48023bf)

- New asynchronous I/O system offering up to 3x performance improvement
- B-Tree skip scan, allowing use of B-Tree indexes without using all columns
- Native `uuidv7` type support
- Generated columns are virtual by default
- Add `NOT NULL` constraints to tables, then validate later without an exclusive lock
- `RETURNING` now provides `old` and `new` values
- `WITHOUT OVERLAPS` clause for `TSRANGE`s in primary keys and constraints
- OAuth 2.0 authentication
- MD5 deprecation for passwords (due for removal in v19)
- Fine-grained control for TLS 1.3 ciphers
- `EXPLAIN ANALYZE` includes `BUFFER` usage
- Monitoring view updates
- Upgrading preserves statistics
- Unlogged partition tables now prohibited - **breaking**