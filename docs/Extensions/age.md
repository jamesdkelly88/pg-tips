# Apache AGE

Graph database layer

## Installation

### Alpine

Not packaged in v3.23+, so requires manual install (or installation from my package repository)

#### Manual

```sh
sudo -s
cd ~
apk add bison flex make perl postgresql18-dev
wget https://dlcdn.apache.org/age/PG18/1.7.0/apache-age-1.7.0-src.tar.gz
tar -xvf apache-age-1.7.0-src.tar.gz
cd apache-age*
make install
```

#### Packaged

See installation on Alpine Linux guide