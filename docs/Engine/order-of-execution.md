# Order of Execution[^1]

- FROM : specify source table
- JOIN : specify additional tables
- WHERE : filter rows
- GROUP BY : aggregate
- HAVING : filter groups
- SELECT : specify columns
- DISTINCT : remove duplicates
- ORDER BY : sort output
- LIMIT : reduce output rows
- OFFSET : skip rows

[^1]: [SQL Lesson 12: Order of execution of a Query](https://sqlbolt.com/lesson/select_queries_order_of_execution)