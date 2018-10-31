# Modify existing `TimeArray`s

Since `TimeArrays` are immutable, they cannot be altered or changed
in-place. In practical application, an existing `TimeArray` might need to
be used to create a new one with many of the same values. This might be
thought of as *changing* the fields of an existing `TimeArray`, but what
actually happens is a new `TimeArray` is created. To allow the use of an
existing `TimeArray` to create a new one, the `update` and `rename`
methods are provided.

## `update`

The `update` method supports adding new observations only.
Older and in-between dates are not supported:

```@repl
using TimeSeries
using MarketData
update(cl, Date(2002,1,1), 111.11)
update(cl, Date(2002,1,1), [111.11])
update(ohlc, Date(2002,1,1), [111.11 222.22 333.33 444.44])
```

## `rename`

The `rename` method allows the column name(s) to be changed:

```@repl
using TimeSeries
using MarketData
rename(cl, :Close′)
rename(cl, [:Close′])
rename(ohlc, [:Open′, :High′, :Low′, :Close′])
rename(ohlc, :Open => :Open′)
rename(ohlc, :Open => :Open′, :Close => :Close′)
rename(ohlc, Dict(:Open => :Open′, :Close => :Close′)...)
rename(Symbol ∘ uppercase ∘ string, ohlc)
rename(uppercase, ohlc, String)
```
