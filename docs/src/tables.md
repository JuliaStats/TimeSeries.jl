# Tables.jl Interface Integration

Quoted from the home page of Tables.jl:

> The [Table.jl](https://github.com/JuliaData/Tables.jl) package provides simple,
> yet powerful interface functions for working with all kinds tabular data through
> predictable access patterns.

The integration provides handy constructor to convert a table between several
types.
The time index of a `TimeArray` is considered as a normal data column named
`timestamp`.

Here this doc shows some example usages of this integration.
Converting table between `DataFrame`s or `CSV` are quite common cases.

## `eachrow` and `eachcol` iterators

In Julia v1.1+, these two functions are supported and baked by `Tables.jl`.

```@repl
using MarketData
for row in eachrow(ohlc)
    time = row.timestamp
    c = row.Close
    # ...
end
```

## `TimeArray` to `DataFrame`

```@repl df-ta
using MarketData, DataFrames
df = DataFrame(ohlc)
```

## `DataFrame` to `TimeArray`

In this case, user needs to point out the column of time index via the
`timestamp` keyword argument.

```@repl df-ta
df′ = DataFrames.rename(df, :timestamp => :A);
first(df′)
TimeArray(df′; timestamp=:A)
```

## Save a `TimeArray` via `CSV.jl`

```julia
using CSV
CSV.write(filename, ta)
```

## Load a `TimeArray` from csv file via `CSV.jl`

```julia
using CSV
TimeArray(CSV.File(filename); timestamp=:timestamp)
```
