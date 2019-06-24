# Array indexing

Indexing out a time series is done with common bracketing semantics.

## Row indexing

### Integer

| Example      | Description                           | Indexing value                 |
|--------------|---------------------------------------|--------------------------------|
| `[1]`        | First row of data only                | single integer                 |
| `[1:3]`      | First through third row only          | integer range                  |
| `[1:2:10]`   | Odd row between first to tenth row    | integer range with step        |
| `[[1:3; 8]]` | First through third row and eight row | integer range & single integer |
| `[end]`      | Last row                              |                                |

Examples in REPL:

```@setup int-indexing
using MarketData
```

```@repl int-indexing
ohlc[1]
ohlc[1:3]
ohlc[1:2:10]
ohlc[[1:3;8]]
ohlc[end]
```

### Date and DateTime

| Example                                      | Description                                | Indexing value |
|----------------------------------------------|--------------------------------------------|----------------|
| `[Date(2000, 1, 3)]`                         | The row containing Jan 3, 2000 timestamp   | single Date    |
| `[[Date(2000, 1, 3), Date(2000, 2, 4)]]`     | The rows containing Jan 3 & Feb 4, 2000    | multiple Dates |
| `[Date(2000, 1, 3):Day(1):Date(2000, 2, 4)]` | The rows between Jan 3, 2000 & Feb 4, 2000 | range of Date  |

Examples in REPL:

```@setup date-indexing
using MarketData
using Dates
```

```@repl date-indexing
ohlc[Date(2000, 1, 3)]
ohlc[Date(2000, 1, 3):Day(1):Date(2000, 2, 4)]
```

## Column indexing

### Symbol

| Example             | Description                            | Indexing value   |
|---------------------|----------------------------------------|------------------|
| `[:Open]`           | The column named `:Open`               | single symbol    |
| `[:Open, :Close]`   | The columns named `:Open` and `:Close` | multiple symbols |
| `[[:Open, :Close]]` | The columns named `:Open` and `:Close` | multiple symbols |

Examples in REPL:

```@setup symbol-indexing
using MarketData
using Dates
```

```@repl symbol-indexing
ohlc[:Open]
ohlc[:Open, :Close]
cols = [:Open, :Close]
ohlc[cols]
```

## Mixed approach

| Example                     | Description                    | Indexing value                |
|-----------------------------|--------------------------------|-------------------------------|
| `[1:3, :Open]`              | `:Open` column & first 3 rows  | single symbol & integer range |
| `[:Open][Date(2000, 1, 3)]` | `:Open` column and Jan 3, 2000 | single symbol & Date          |

Examples in REPL:

```@setup mixed-indexing
using MarketData
using Dates
```

```@repl mixed-indexing
ohlc[1:3, :Open]
ohlc[:Open][Date(2000, 1, 3)]
```
