# pg_tle (Trusted Language Extensions)

[Repository](https://github.com/aws/pg_tle)

Because most cloud providers don't grant superuser or filesystem access, adding extensions that aren't packaged is not possible. To reduce the impact of this, Amazon developed `pg_tle` - the trusted language extension provider, which allows extensions to be created and deployed to RDS instances without superuser permissions using trusted languages (PL/pgSQL, JavaScript, or Perl).

## Installation

### Alpine

Not packaged, so requires manual install (or installation from my package repository)

#### Manual

```sh
sudo -s
cd ~
apk add build-base flex make postgresql18-dev
wget https://github.com/aws/pg_tle/archive/refs/tags/v1.5.2.tar.gz
tar -xvf v1.5.2.tar.gz
cd pg_tle*
make install
```

#### Packaged

See [installation on Alpine Linux guide](../Guides/alpine.md)

### Settings

```
shared_preload_libraries = 'pg_tle' # requires restart
```

## Usage

- Install extension (requires superuser)
    ```sql
    CREATE EXTENSION pg_tle; --requires superuser
    ```
- Grant control (requires superuser)
    ```sql
    GRANT pgtle_admin TO postgres;
    GRANT pgtle_admin TO <username>;
    ```
- Define an extension
    ```sql
    SELECT pgtle.install_extension
    (
        'name',
        'version number',
        'description',
        $_pg_tle_$
            <sql scripts>
        $_pg_tle_$
    ); -- requires pgtle_admin
    ```

- Install extension
    ```sql
    CREATE EXTENSION name; 
    -- requires CREATE on the database
    -- the creator becomes the owner, so 'SET ROLE role_name' beforehand if it needs to be shared
    ```
- Update definition
    ```sql
    SELECT pgtle.install_update_path
    (
        'name',
        'old_version_number',
        'new_version_number',
        $_pg_tle_$
            <sql scripts>
        $_pg_tle_$
    ); -- requires pgtle_admin

    SELECT pgtle.set_default_version('name', 'new_version_number'); -- requires pgtle_admin
    ```
- Install update
    ```sql
    ALTER EXTENSION name UPDATE; -- requires CREATE on the database
    ```
- Uninstall extension
    ```sql
    DROP EXTENSION name; -- must be the owner (who created the extension)
    ```

- Delete definition
    ```sql
    SELECT pgtle.uninstall_extension('name'); -- requires pgtle_admin
    ```

## Example extensions

### pg_distance[^1]

```sql
SELECT pgtle.install_extension
(
 'pg_distance',
 '0.1',
  'Distance functions for two points',
$_pg_tle_$
    CREATE FUNCTION dist(x1 float8, y1 float8, x2 float8, y2 float8, norm int)
    RETURNS float8
    AS $$
      SELECT (abs(x2 - x1) ^ norm + abs(y2 - y1) ^ norm) ^ (1::float8 / norm);
    $$ LANGUAGE SQL;

    CREATE FUNCTION manhattan_dist(x1 float8, y1 float8, x2 float8, y2 float8)
    RETURNS float8
    AS $$
      SELECT dist(x1, y1, x2, y2, 1);
    $$ LANGUAGE SQL;

    CREATE FUNCTION euclidean_dist(x1 float8, y1 float8, x2 float8, y2 float8)
    RETURNS float8
    AS $$
      SELECT dist(x1, y1, x2, y2, 2);
    $$ LANGUAGE SQL;
$_pg_tle_$
);

CREATE EXTENSION pg_distance;

SELECT manhattan_dist(1, 1, 5, 5);
SELECT euclidean_dist(1, 1, 5, 5);

```
### pg_security

```sql title="pg_security_views.sql"
--8<-- "includes/pg_security_views.sql"

CREATE EXTENSION pg_security_views;

select * from pgsecurity.role_members;
```


[^1]: [Quick Start guide](https://github.com/aws/pg_tle/blob/main/docs/02_quickstart.md)