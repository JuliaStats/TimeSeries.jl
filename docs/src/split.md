# Splitting by conditions

Specific methods for segmenting on time ranges or if condition is met is
supported with the following methods.

## `when`

The `when` methods allows aggregating elements from a `TimeArray` into
specific time periods, such as Mondays or the month of October:

```@repl
using TimeSeries
using MarketData
when(cl, dayofweek, 1)
when(cl, dayname, "Monday")
```

The period argument holds a valid `Date` method. Below are currently
available alternatives.

| Dates method       | Example                  |
|:------------------ |:------------------------ |
| `day`              | Jan 3, 2000 = 3          |
| `dayname`          | Jan 3, 2000 = "Monday"   |
| `week`             | Jan 3, 2000 = 1          |
| `month`            | Jan 3, 2000 = 1          |
| `monthname`        | Jan 3, 2000 = "January"  |
| `year`             | Jan 3, 2000 = 2000       |
| `dayofweek`        | Monday = 1               |
| `dayofweekofmonth` | Fourth Monday in Jan = 4 |
| `dayofyear`        | Dec 31, 2000 = 366       |
| `quarterofyear`    | Dec 31, 2000 = 4         |
| `dayofquarter`     | Dec 31, 2000 = 93        |

## `from`

The `from` method truncates a `TimeArray` starting with the date passed to
the method:

```@repl
using TimeSeries
using MarketData

from(cl, Date(2001, 12, 27))
```

## `to`

The `to` method truncates a `TimeArray` after the date passed to the
method:

```@repl
using TimeSeries
using MarketData

to(cl, Date(2000, 1, 5))
```

## `findwhen`

The `findwhen` method test a condition and returns a vector of `Date` or
`DateTime` where the condition is `true`:

```@repl
using TimeSeries
using MarketData

green = findwhen(ohlc[:Close] .> ohlc[:Open]);
typeof(green)
ohlc[green]
```

## `findall`

The `findall` method tests a condition and returns a vector of `Int`
representing the row in the array where the condition is `true`:

```@repl
using TimeSeries
using MarketData

red = findall(ohlc[:Close] .< ohlc[:Open]);
typeof(red)
ohlc[red]
```

The following example won't create a temporary `Bool` vector, and gains better
performance.

```@setup findall
using TimeSeries
using MarketData
```

```@repl findall
findall(>(100), cl)
```

## Splitting by head and tail

### `head`

The `head` method defaults to returning only the first value in a
`TimeArray`. By selecting the second positional argument to a different
value, the user can modify how many from the top are selected:

```@repl
using TimeSeries
using MarketData

head(cl)
```

### `tail`

The `tail` method defaults to returning only the last value in a
`TimeArray`. By selecting the second positional argument to a different
value, the user can modify how many from the bottom are selected:

```@repl
using TimeSeries
using MarketData

tail(cl)
tail(cl, 3)
```

## Splitting by period

Splitting data by a given function, e.g. `Dates.day` into periods.

```@repl
using TimeSeries
using MarketData

split(cl, Dates.day)
```
