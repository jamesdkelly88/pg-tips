# Numbers

| Type | Aliases | Size | Range | Since[^1] |
|---|---|---|---|---|
| smallint | int2 | 2B | ±32,767 | 6.3 | 
| integer | int4<br/>int | 4B | ±2,147,483,647 | 6.3 |
| bigint | int8 | 8B | ±9,223,372,036,854,775,807 | 6.4 |
| numeric | decimal | variable | 131,072 before d.p., 16,383 after | 7.0 |
| real | float4 | 4B | 1e±37 with 6 d.p | 6.3 |
| double precision | float<br/>float8 | 8B | 1e±308 with 15 d.p. | 6.3 |
| smallserial | serial2 | 2B | 1 to 32,767 auto-incrementing | 9.2 |
| serial | serial4 | 4B | 1 to 2,147,483,647 auto-inc. | 6.3 |
| bigserial | serial8 | 8B | 1 to 9,223,372,036,854,775,807 auto-inc. | 8.0 |
| money | | 8B | ±92,233,720,368,547,758.07 | 8.3 |
| ~~money~~[^2] | | 4B | ±21474836.47 | 6.3 |

[^1]: I've only found documentation online for version 6.3+, so some of these types may have existed earlier. v6.3 was released in 1998 so this is unlikely to have any real significance.
[^2]: Resized to 8 byte version in `v8.3`

## Numeric

Precise, but slower than other types.

Defined as `numeric (precision, scale)` where:
- precision: number of digits on both sides (max 1000)
- scale: number of decimal places (max 1000)

Can be defined without scale - defaults to zero (equivalent to integer)

Can be defined without precision or scale - becomes unconstrained (max size as per table)

Exceeding scale causes **rounding** (away from 0), exceeding precision causes an **error**

Since `v15`, a negative scale can be declared to reduce significant figures (e.g. `-3` rounds to nearest thousand) - not part of the SQL standard

Scale can exceed precision (e.g. `3,5` has 3 sig. figs but 5 d.p, allowed range ±0.00999)

Has special values `Infinity`/`inf`, `-Infinity`/`-inf` and `NaN` - these are case insensitive quoted strings in SQL statements. Infinity values can only be stored unconstrained.

- `n` + `inf` = `inf`
- `inf` - `inf` = `NaN`
- `n` (any operator) `NaN` = `NaN` (except `NaN^0`, which = 1)
- `NaN` = `NaN`
- `NaN` ≠ any other number
- `NaN` > every other number 

## Floating Point

Inexact - can lead to skew and weird equlity results

Exceeding capacity causes an **error**

Rounding (to nearest even number) can occur if precicion is too high

Numbers too close to zero that cannot be represented as non-zero cause an **error**

Output as text form of shortest precise decimal value - legcy behaviour was different and can be re-enabled with the `extra_float_digits` parameter

Supports special values `inf`,`-inf` and `NaN` - see above

Can also be declared as `float(n)`: 1 - 24 -> `real`, 24 - 53 -> `double precision`

## Serial

Not a true type - represents the cretion of a sequence of the underlying integer size

```sql
CREATE TABLE table_name(
    column_name serial NOT NULL
);
```

```sql
CREATE SEQUENCE table_name_seq AS integer;
CREATE TABLE table_name(
    column_name INTEGER NOT NULL DEFAULT nextval('table_name_seq')
);
ALTER SEQUENCE table_name_seq OWNED BY table_name.column_name -- causes drop on column drop
```

Normally wants `UNIQUE` or `PRIMARY KEY` defining - not automatic

To insert into a `serial`, either omit from the list of columns or specify `default`

If you drop the sequence but not the column, th default expression is removed

## Money

