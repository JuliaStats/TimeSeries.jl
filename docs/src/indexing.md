# Array indexing

Indexing out a time series is done with common bracketing semantics.

## Integers

| Example      | Description                           | Indexing value                 |
|--------------|---------------------------------------|--------------------------------|
| `[1]`        | First row of data only                | single integer                 |
| `[1:3]`      | First through third row only          | integer range                  |
| `[1:2:10]`   | Odd row between first to tenth row    | integer range with step        |
| `[[1:3; 8]]` | First through third row and eight row | integer range & single integer |

Examples in REPL:

```@repl
using MarketData
ohlc[1]
ohlc[1:3]
ohlc[1:2:10]
ohlc[[1:3;8]]
```

## Strings

| Example             | Description                          | Indexing value   |
|---------------------|--------------------------------------|------------------|
| `["Open"]`          | The column named "Open"              | single string    |
| `["Open", "Close"]` | The columns named "Open" and "Close" | multiple strings |

Examples in REPL:

```@repl
using MarketData
ohlc["Open"]
ohlc["Open", "Close"]
```

# Date and DateTime

| Example                                  | Description                                | Indexing value |
|------------------------------------------|--------------------------------------------|----------------|
| `[Date(2000, 1, 3)]`                     | The row containing Jan 3, 2000 timestamp   | single Date    |
| `[[Date(2000, 1, 3), Date(2000, 2, 4)]]` | The rows containing Jan 3 & Jan 4, 2000    | multiple Dates |
| `[Date(2000, 1, 3):Date(2000, 2, 4)]`    | The rows between Jan 1, 2000 & Feb 1, 2000 | range of Date  |

Examples in REPL:

```@repl
using MarketData
ohlc[Date(2000, 1, 3)]
ohlc[Date(2000, 1, 3):Date(2000, 2, 4)]
```

## Mixed approach

| Example                      | Description                   | Indexing value                |
|------------------------------|-------------------------------|-------------------------------|
| `["Open"][1:3]`              | "Open" column & first 3 rows  | single string & integer range |
| `["Open"][Date(2000, 1, 3)]` | "Open" column and Jan 3, 2000 | single string & Date          |

Examples in REPL:

```@repl
using MarketData
ohlc["Open"][1:3]
ohlc["Open"][Date(2000, 1, 3)]
```
