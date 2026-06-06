# Installing on Alpine

## Installing Alpine Linux

1. Boot from image/ISO
1. Login as `root` with no password
1. Run `setup-alpine`
    1. Select a keymap (`gb`) and variant (`gb`)
    1. Enter hostname
    1. Configure interface
    1. Set root user password to `root`
    1. Select a time zone (`Europe/London`)
    1. Configure proxy
    1. Select NTP client (`busybox`)
    1. Edit `/etc/apk/repositories` by hand:
        ```
        http://dl-cdn.alpinelinux.org/alpine/v3.23/main
        http://dl-cdn.alpinelinux.org/alpine/v3.23/community
        ```
    1. Setup a user (`james`)
    1. Select SSH server (`openssh`)
    1. Select disk to install to
         - Use as `sys`  <!-- TODO: Try LVM -->
1. Reboot
1. Login as root
1. Install sudo
    ```sh
    apk update
    apk add sudo
    visudo # uncomment the line: %wheel ALL=(ALL:ALL) ALL
    ```
1. Logout
1. Login as user
1. Lock root user
    ```sh
    sudo passwd -l root
    ```
1. Setup for ansible automation
    ```sh
    sudo adduser ansible
    sudo addgroup ansible wheel
    sudo apk add python3
    ```
1. Install PostgreSQL
    ```sh
    sudo apk add postgresql18 postgresql18-contrib # you must pick a major version for the package to avoid unexpected upgrades!
    sudo rc-update add postgresql # run service at startup
    sudo rc-service postgresql start # start service
    ```
1. Edit `/etc/postgresql18/postgresql.conf`:
    - Uncomment `#listen_addresses = 'localhost'` and change to `listen_addresses = '*'` to allow network connections
1. Edit `/etc/postgresql18/pg_hba.conf`:
    - Change `host all all 127.0.0.1/32 md5` to `host all all 0.0.0.0/0 scram-sha-256` (do not use `md5` as it is insecure and deprecated)
1. Restart the service
    ```sh
    sudo rc-service postgresql restart
    ```
1. Switch to the `postgres` user
    ```sh
    sudo su postgres
    cd ~
    ```
1. Run `psql`
    1. Set `postgres` user password
        ```
        \password
        ```
    1. Create additional user
        ```
        Create user james with encrypted password 'password';
        ```
    1. Create database owner role
        ```
        create role test_owner with nologin;
        ```
    1. Create database
        ```
        create database test with owner = test_owner;
        ```
    1. Add users to database owner role
        ```
        grant test_owner to james;
        ```
1. Connect from another machine using `psql`/`pgadmin4` and the credentials created
1. Install extensions and restart service