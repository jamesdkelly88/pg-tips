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

Age uses OpenCypher as its query language. The recommended naming conventions[^1] are:
- PascalCase for node types (labels) 
- SCREAMING_SNAKE_CASE for edge types
- camelCase for properties

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
        CREATE (:NodeType1),(:NodeType2)
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
    | "{""id"": 1125899906842625, ""label"": ""NodeType1"", ""properties"": {}}::vertex" |

- Create edge
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        MATCH (a:Node1), (b:Node2)
        CREATE (a)-[e:REL_TYPE]->(b)
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
    | "{""id"": 1407374883553281, ""label"": ""NodeType2"", ""properties"": {}}::vertex" | "{""id"": 1688849860263937, ""label"": ""REL_TYPE"", ""end_id"": 1407374883553281, ""start_id"": 1125899906842626, ""properties"": {}}::edge" | "{""id"": 1125899906842626, ""label"": ""NodeType1"", ""properties"": {}}::vertex" |
    | "{""id"": 1125899906842626, ""label"": ""NodeType1"", ""properties"": {}}::vertex" | "{""id"": 1688849860263937, ""label"": ""REL_TYPE"", ""end_id"": 1407374883553281, ""start_id"": 1125899906842626, ""properties"": {}}::edge" | "{""id"": 1407374883553281, ""label"": ""NodeType2"", ""properties"": {}}::vertex" |

- Create with properties
- Filter by property

- delete a vertex
    ```sql
    SELECT * 
    FROM cypher('graph_name', $$
        MATCH (v:NodeType1)
        DELETE v
    $$) as (v agtype);
    ```

- delete graph
    ```sql
    SELECT * FROM drop_graph('graph_name', true); 
    ```


## Bulk Import[^2]



1. Create a CSV file for each type (label) of node
2. Create a CSV for each type of edge
3. Copy files to server - limited to path `/tmp/age/` <!-- TODO: verify this -->
4. Create graph
5. Load nodes
6. Load edges
7. Count results to confirm


## Sample data

### London Underground

[Repository](https://github.com/neo4j-partners/neo4j-transport-for-london)

[Transformation script](./age_underground_prep.ps1)

```sql title="Import stations"

```

```sql title="Import line"

```







[^1]: [Naming syntax](https://neo4j.com/docs/cypher-manual/current/syntax/naming/)

[^2]: [Bulk import instructions](https://age.apache.org/age-manual/master/intro/agload.html)