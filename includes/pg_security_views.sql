SELECT pgtle.install_extension
(
    'pg_security_views',
    '0.1',
    'Views for simplifying PostgreSQL permission checks',
    $_pg_tle_$
        CREATE SCHEMA IF NOT EXISTS pgsecurity;

        GRANT USAGE ON SCHEMA pgsecurity TO PUBLIC;
        ALTER DEFAULT PRIVILEGES IN SCHEMA pgsecurity GRANT SELECT ON TABLES TO PUBLIC;

        CREATE OR REPLACE VIEW pgsecurity.role_members AS
            SELECT
                m.rolname as member_name,
                r.rolname as role_name,
                am.admin_option as with_admin,
                am.inherit_option as with_inherit,
                am.set_option as with_set,
                g.rolname as grantor
            FROM pg_auth_members am
            INNER JOIN pg_roles r on am.roleid = r.oid
            INNER JOIN pg_roles m on am.member = m.oid
            INNER JOIN pg_roles g on am.grantor = g.oid;
    $_pg_tle_$
);