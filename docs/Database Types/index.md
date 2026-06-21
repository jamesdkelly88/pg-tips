---
tags:
- draft
---
# Database Types

I read a fascinating article by Ashish Pratap Singh about [15 types of database and when to use them](https://blog.algomaster.io/p/15-types-of-databases), and it got me thinking about the extensibility of PostgreSQL, and how many of these database types it could act as (or emulate quite closely).

![Database types article diagram](https://substackcdn.com/image/fetch/$s_!PvX_!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F06ea11e0-0161-4f3c-a2ed-99c766b261a6_1944x1148.png)

TLDR: Yep, all of them to some extent.

## Relational

Tables, columns and rows. What most people think of when you say database

### Result

Yes - this is the main mode for PostgreSQL, so it does this very well

### Other options

MySQL, Oracle, SQL Server, DB2, Microsoft Access, SQLite and many others

### Example

``` sql title="relational.sql"
CREATE TABLE customers (
    customer_id int PRIMARY KEY,
    customer_name varchar(100),
    country varchar(100)
);
CREATE TABLE orders (
    order_id int PRIMARY KEY,
    customer_id int REFERENCES customers(customer_id),
    order_date date
);

INSERT INTO customers (customer_id, customer_name, country)
    VALUES (1, 'John Smith', 'UK');
INSERT INTO orders (order_id, customer_id, order_date)
    VALUES (1, 1, '2020-01-01');

SELECT *
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.order_id;
```

| customer_id | customer_name | country | order_id | customer_id | order_date |
|---|---|---|---|---|---|
| 1 | John Smith | UK | 1 | 1 | 2020-01-01 |

## Key-Value Store

NoSQL database that stores values behind unique keys. Good for fast read/write and scaling, when no relationships are required. Session stores and caches are typical use cases.

### Result

Yes - can create a 2-column table with unique key and value, or a key-value column using the `hstore` extension and data type.

### Other options

Redis, DynamoDB, etcd, Windows Registry

### Example

``` sql title="key-value.sql"
CREATE EXTENSION hstore;
CREATE TABLE books (
    id serial PRIMARY KEY,
    title varchar(255),
    attr hstore
);
INSERT INTO books (title, attr)
    VALUES ('1984',
        '"author" => "George Orwell",
        "published" => "1949-06-08",
        "language" => "English",
        "fiction" => true');

SELECT title, attr -> 'author' AS author
FROM books
WHERE attr -> 'fiction' = 'true';
```

| title | author |
|---|---|
| 1984 | George Orwell |