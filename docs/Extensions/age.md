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
5. Create labels
6. Load nodes (requires `pg_read_server_files` permission)
7. Load edges (requires `pg_read_server_files` permission)
8. Count results to confirm


## Sample data

### London Underground

[Repository](https://github.com/neo4j-partners/neo4j-transport-for-london)

[Transformation script](./age_underground_prep.ps1)

#### Loading

```sql title="Create graph"
SET search_path = ag_catalog, "$user", public;
SELECT * FROM create_graph('london_underground');
```

```sql title="Import stations"
SELECT create_vlabel('london_underground','Station');
SELECT load_labels_from_file('london_underground','Station','nodes_station.csv'); 
SELECT stations::int
    FROM cypher('london_underground', $$
        MATCH (v:Station)
        RETURN count(v)
    $$) as (stations agtype);
-- result should be 653
```

```sql title="Import lines"
SELECT create_elabel('london_underground','BAKERLOO');
SELECT create_elabel('london_underground','CENTRAL');
SELECT create_elabel('london_underground','CIRCLE');
SELECT create_elabel('london_underground','DISTRICT');
SELECT create_elabel('london_underground','DLR');
SELECT create_elabel('london_underground','ELIZABETH');
SELECT create_elabel('london_underground','HAMMERSMITH_AND_CITY');
SELECT create_elabel('london_underground','JUBILEE');
SELECT create_elabel('london_underground','METROPOLITAN');
SELECT create_elabel('london_underground','NORTHERN');
SELECT create_elabel('london_underground','OVERGROUND');
SELECT create_elabel('london_underground','PICCADILLY');
SELECT create_elabel('london_underground','VICTORIA');
SELECT create_elabel('london_underground','WATERLOO_AND_CITY');
SELECT load_edges_from_file('london_underground','BAKERLOO','edges_bakerloo.csv');
SELECT load_edges_from_file('london_underground','CENTRAL','edges_central.csv');
SELECT load_edges_from_file('london_underground','CIRCLE','edges_circle.csv');
SELECT load_edges_from_file('london_underground','DISTRICT','edges_district.csv');
SELECT load_edges_from_file('london_underground','DLR','edges_dlr.csv');
SELECT load_edges_from_file('london_underground','ELIZABETH','edges_elizabeth.csv');
SELECT load_edges_from_file('london_underground','HAMMERSMITH_AND_CITY','edges_hammersmith and city.csv');
SELECT load_edges_from_file('london_underground','JUBILEE','edges_jubilee.csv');
SELECT load_edges_from_file('london_underground','METROPOLITAN','edges_metropolitan.csv');
SELECT load_edges_from_file('london_underground','NORTHERN','edges_northern.csv');
SELECT load_edges_from_file('london_underground','OVERGROUND','edges_overground.csv');
SELECT load_edges_from_file('london_underground','PICCADILLY','edges_piccadilly.csv');
SELECT load_edges_from_file('london_underground','VICTORIA','edges_victoria.csv');
SELECT load_edges_from_file('london_underground','WATERLOO_AND_CITY','edges_waterloo and city.csv');
SELECT agtype_to_text(line) line, edges::int
    FROM cypher('london_underground', $$
        MATCH ()-[e]-()
        RETURN type(e), count(e)
    $$) as (line agtype, edges agtype);
-- result should be double the size of the source file as edges are bi-directional
-- you're scanning the whole graph here so it may take a while!
```

#### Quering

- How many stations are on the Jubilee line?
    ```sql
    SELECT s::int
        FROM cypher('london_underground', $$
            MATCH (s)-[:JUBILEE]-()
            RETURN COUNT (DISTINCT s)
        $$) as (s agtype);
    ```

    | s |
    | --- |
    | 27 |

- Which lines go through Bank?
  ```sql
    SELECT agtype_to_text(e) as line
        FROM cypher('london_underground', $$
            MATCH ({name: 'Bank'})-[e]-()
            RETURN DISTINCT type(e)
        $$) as (e agtype);
  ```

  | line |
  | --- |
  | CENTRAL |
  | DLR |
  | NORTHERN |
  | WATERLOO_AND_CITY |

- Which stations are within 2 stops of Baker Street?
  ```sql
    SELECT agtype_to_text(s) as station
        FROM cypher('london_underground', $$
            MATCH (n {name: 'Baker Street'})-[*1..2]-(s)
            WHERE s.name <> n.name
            RETURN DISTINCT s.name
        $$) as (s agtype)
    ORDER BY station;
  ```

  | station |
  | --- |
  | Bond Street |
  | Edgware Road |
  | ... (16 rows total) |

- Which stations are within 2 stops of Baker Street, and on which lines?
  ```sql
    SELECT
        agtype_to_text(destination) AS destination,
        stops,
        agtype_to_text(line) AS line
    FROM cypher('london_underground', $$
        MATCH (n {name:'Baker Street'})-[r1]-(m)-[r2]-(s)
        WHERE s.name <> n.name
        AND type(r1) = type(r2)

        RETURN
            s.name AS destination,
            2 AS stops,
            type(r1) AS line

        UNION

        MATCH (n {name:'Baker Street'})-[r]-(s)
        WHERE s.name <> n.name

        RETURN
            s.name AS destination,
            1 AS stops,
            type(r) AS line
    $$) AS (destination agtype, stops agtype, line agtype)
    ORDER BY stops, destination;
  ```

  | destination | stops | line |
  | --- | --- | --- |
  | Bond Street | 1 | JUBILEE |
  | Edgware Road | 1 | CIRCLE |
  | ... (20 rows total) | | |

- How many stops between Bond Street and Stratford?
    1. Get common lines
    ```sql
    SELECT agtype_to_text(line) AS line
    FROM cypher('london_underground', $$
        MATCH (a {name:'Bond Street'})-[r]-()
        RETURN DISTINCT type(r) AS line
    $$) AS (line agtype)

    INTERSECT

    SELECT agtype_to_text(line) AS line
    FROM cypher('london_underground', $$
        MATCH (b {name:'Stratford'})-[r]-()
        RETURN DISTINCT type(r) AS line
    $$) AS (line agtype);
    ```

    | line |
    | --- |
    | CENTRAL |
    | ELIZABETH |
    | JUBILEE |

    2. Get the path length for each line
    ```sql
    SELECT agtype_to_text(line) as line, stops::int
    FROM cypher('london_underground', $$
        MATCH p = (a {name:'Bond Street'})-[r:CENTRAL*1..30]-(b {name:'Stratford'})
    RETURN 'Central', size(r)
    $$) AS (line agtype, stops agtype)
    UNION
    SELECT agtype_to_text(line) as line, stops::int
    FROM cypher('london_underground', $$
        MATCH p = (a {name:'Bond Street'})-[r:ELIZABETH*1..30]-(b {name:'Stratford'})
    RETURN 'Elizabeth', size(r)
    $$) AS (line agtype, stops agtype)
    UNION
    SELECT agtype_to_text(line) as line, stops::int
    FROM cypher('london_underground', $$
        MATCH p = (a {name:'Bond Street'})-[r:JUBILEE*1..30]-(b {name:'Stratford'})
    RETURN 'Jubilee', size(r)
    $$) AS (line agtype, stops agtype)
    ORDER BY line
    ```

    | line | stops |
    | --- | --- |
    | Central | 10 |
    | Elizabeth | 5
    | Jubilee | 12 |

- What is the shortest route from Richmond to Epping?
  ```sql
    SELECT
        interchange,
        district_stops::int AS district_stops,
        central_stops::int AS central_stops,
        (district_stops::int + central_stops::int) AS total_stops
    FROM cypher('london_underground', $$
        MATCH p1 = (r {name:'Richmond'})-[d:DISTRICT*1..60]-(x)
        MATCH p2 = (x)-[c:CENTRAL*1..60]-(e {name:'Epping'})

        RETURN
            x.name AS interchange,
            size(d) AS district_stops,
            size(c) AS central_stops
    $$) AS (
        interchange agtype,
        district_stops agtype,
        central_stops agtype
    )
    ORDER BY total_stops
    LIMIT 1;
  ```

  | interchange | district_stops | central_stops | total_stops |
  | --- | --- | --- | --- |
  | "Notting Hill Gate" | 11 | 24 | 35 |

  It is worth noting that this particular query constrains the route to reduce the number of paths returned, so may not be the true shortest route. There is also an issue with the sample data not considering Bank and Monument as the same station, so the only other interchange route returned in "Ealing Broading", 38 stops.

<!-- TODO:
- fix indenting
- show process for merging the Bank/Monument nodes -->

## Visualising

<!-- TODO: -->






[^1]: [Naming syntax](https://neo4j.com/docs/cypher-manual/current/syntax/naming/)

[^2]: [Bulk import instructions](https://age.apache.org/age-manual/master/intro/agload.html)