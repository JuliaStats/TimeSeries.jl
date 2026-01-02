# Modify existing `TimeArray`s

```@setup base
using TimeSeries
using MarketData
```

## `rename` and `rename!`

The `rename` method allows the column name(s) to be changed.
The `rename!` is used for in-place update.

```@repl base
first(rename(cl, :Close′))
first(rename(cl, [:Close′]))
first(rename(ohlc, [:Open′, :High′, :Low′, :Close′]))
first(rename(ohlc, :Open => :Open′))
first(rename(ohlc, :Open => :Open′, :Close => :Close′))
first(rename(ohlc, Dict(:Open => :Open′, :Close => :Close′)...))
first(rename(Symbol ∘ uppercase ∘ string, ohlc))
first(rename(uppercase, ohlc, String))
```

See [`rename`](@ref) and [`rename!`](@ref) in the [Public API Reference](@ref) for detailed documentation.
