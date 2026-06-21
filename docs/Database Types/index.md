---
tags:
- draft
---
# Database Types

I read a fascinating article by Ashish Pratap Singh about [15 types of database and when to use them](https://blog.algomaster.io/p/15-types-of-databases), and it got me thinking about the extensibility of PostgreSQL, and how many of these database types it could act as (or emulate quite closely).

TLDR: Yep, all of them to some extent.

## Relational

Tables, columns and rows. What most people think of when you say database

**Result:** Yes - this is the main mode for PostgreSQL, so it does this very well

**Other options:** MySQL, Oracle, SQL Server, DB2, Microsoft Access, SQLite and many others

**Example:**

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