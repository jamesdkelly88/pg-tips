# Apache AGE

Graph database layer using [Cypher](../Languages/cypher.md)

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

### Settings

```
shared_preload_libraries = 'age' # requires restart
session_preload_libraries = 'age' # preloads libraries, allows non-superuser usage
```

## Usage

- Install extension (requires superuser)
    ```sql
    CREATE EXTENSION age; --requires superuser
    ```
- Set search path (must be done for every session) 
    <!-- TODO: preset? -->
    ```sql
    SET search_path = ag_catalog, "$user", public;
    ```
- Create graph
    ```sql
    SELECT * FROM create_graph('graph_name');
    ```
- Check graph exists
    ```sql
    SELECT * FROM graph_exists('graph_name');
    ```
- Create vertices (nodes)
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        CREATE (:node1),(:node2)
    $$) as (v agtype);
    ```
- List vertices
    ```sql
    SELECT * 
        FROM cypher('graph_name', $$
            MATCH (v)
            RETURN v
        $$) as (v agtype);
    ```

    | v (agtype) |
    | --- |
    | "{""id"": 1125899906842625, ""label"": ""node1"", ""properties"": {}}::vertex" |

- Create edge
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        MATCH (a:node1), (b:node2)
        CREATE (a)-[e:RELTYPE]->(b)
        RETURN e
    $$) as (e agtype);
    ```

- List edges
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        MATCH (a)-[e]-(b)
        RETURN a,e,b
    $$) as (a agtype, e agtype, b agtype);
    ```

    | a (agtype) | e (agtype) | b (agtype) |
    | --- | --- | --- |
    | "{""id"": 1407374883553281, ""label"": ""node2"", ""properties"": {}}::vertex" | "{""id"": 1688849860263937, ""label"": ""RELTYPE"", ""end_id"": 1407374883553281, ""start_id"": 1125899906842626, ""properties"": {}}::edge" | "{""id"": 1125899906842626, ""label"": ""node1"", ""properties"": {}}::vertex" |
    | "{""id"": 1125899906842626, ""label"": ""node1"", ""properties"": {}}::vertex" | "{""id"": 1688849860263937, ""label"": ""RELTYPE"", ""end_id"": 1407374883553281, ""start_id"": 1125899906842626, ""properties"": {}}::edge" | "{""id"": 1407374883553281, ""label"": ""node2"", ""properties"": {}}::vertex" |

- Create with properties
- Filter by property

- delete a vertex
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        MATCH (v:node1)
        DELETE v
    $$) as (v agtype);
    ```

- delete graph
    ```sql
    SELECT * FROM drop_graph('graph_name', true); 
    ```

## Sample data

### London Underground

[Repository](https://github.com/neo4j-partners/neo4j-transport-for-london)