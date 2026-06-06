# Extensions

## Background

PostgreSQL is designed to be easily extensible, and has a vast ecosystem of extensions. Every OS package and SaaS provider offer different extensions as standard (usually via the `contrib` package). Additional extensions can be installed through software packages, provider configuration, or built from source.

An extension is a package containing scripts, types, functions and compiled C code to extend PostgreSQL's features.

Extensions can be either `trusted` or `untrusted`, determined by an entry in the extension's control file (see [structure](#structure)). Only members of the `superuser` role can install untrusted extensions.

Because most cloud providers don't grant superuser or filesystem access, adding extensions that aren't packaged is not possible. To reduce the impact of this, Amazon developed [pg_tle](/docs/Extensions/pg_tle.md) - the trusted language extension provider, which allows extensions to be created and deployed to RDS instances without superuser permissions using trusted languages (PL/pgSQL, JavaScript, or Perl).

## Usage

- View installed extensions (database-specific)
    ```sql
    SELECT * FROM pg_extension;
    ```

    | oid | extname | extowner | extnamespace | extrelocatable | extversion | extconfig | extcondition |
    | --- | --- | --- | --- | --- | --- | --- | --- |
    | 13319 | plpgsql | 10 | 11 | false | 1.0 | [null] | [null] |

- View available extensions (host-specific)
    ```sql
    SELECT * FROM pg_available_extensions;
    ```
    | name | default_version | installed_version | comment |
    | --- | --- | --- | --- |
    | autoinc | .0 | [null] | functions for autoincrementing fields |
    | hstore | 1.8 | [null] | data type for storing sets of (key, value) pairs |
    | plpgsql | 1.0 | 1.0 | PL/pgSQL procedural language |
    | xml2 | 1.2 | [null] | XPath querying and XSLT |

- Install extension to server
    - Extensions are installed on the host in `SHAREDIR/extension`.
    - You can get the location of `SHAREDIR` by running `pg_config --sharedir` (`/usr/share/postgresql18`)
    - Every extension includes a `.control` file
        ```ini
        # xml2 extension
        comment = 'XPath querying and XSLT'
        default_version = '1.2'
        module_pathname = '$libdir/pgxml'
        # XXX do we still need this to be non-relocatable?
        relocatable = false
        ```
    - Every extension includes at least 1 `.sql` file to define functions, types etc
        ```sql
        /* contrib/xml2/xml2--1.1.sql */

        -- complain if script is sourced in psql, rather than via CREATE EXTENSION
        \echo Use "CREATE EXTENSION xml2" to load this file. \quit

        --SQL for XML parser

        -- deprecated old name for xml_is_well_formed
        CREATE FUNCTION xml_valid(text) RETURNS bool
        AS 'xml_is_well_formed'
        LANGUAGE INTERNAL STRICT STABLE PARALLEL SAFE;
        ...
        ```
    - Additional files define upgrade actions between versions
        ```sql
        /* contrib/xml2/xml2--1.0--1.1.sql */

        -- complain if script is sourced in psql, rather than via ALTER EXTENSION
        \echo Use "ALTER EXTENSION xml2 UPDATE TO '1.1'" to load this file. \quit

        ALTER FUNCTION xml_valid(text) PARALLEL SAFE;  
        ...    
        ```
    - Additional libraries are defined in the `.control` file as `module_pathname`
    - You can get the location of `LIBDIR` by running `pg_config --libdir` (`/usr/lib`). For the example above, the full path to the module is `/usr/lib.postgresql18/pgxml.so`


- Extensions that need loading at startup to register shared memory or lwlocks need adding to the setting `shared_preload_libraries` (comma separated) OR . Updating this setting requires a service restart. Examples include:
    - pg_cron
    - pg_stat_statements

- Install extension to database
    ```sql
    CREATE EXTENSION name;
    ```




## Structure

## Reference

[Alpine Packages](https://pkgs.alpinelinux.org/packages?name=postgresql*-*&branch=v3.23&repo=&arch=x86_64&origin=&flagged=&maintainer=)

[AWS RDS Extensions](https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-extensions.html)
