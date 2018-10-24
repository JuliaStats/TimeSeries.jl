# Getting Started

`TimeSeries` is a registered package.
To add it to your Julia packages, simply do the following in REPL:

```julia
julia> Pkg.add("TimeSeries")
```

Throughout this tutorial, we'll be using historical financial data sets,
which are made available in the `MarketData` package. `MarketData` is also
registered and can be added:

```julia
julia> Pkg.add("MarketData")
```

To create dummy data without using the `MarketData` package, simply use
the following code block:

```@setup dummy
using TimeSeries
```

```@repl dummy
using Dates
dates = Date(2018, 1, 1):Day(1):Date(2018, 12, 31)
ta = TimeArray(dates, rand(length(dates)))
```
