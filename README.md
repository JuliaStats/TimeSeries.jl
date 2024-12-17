# TimeSeries.jl

[![Latest Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaStats.github.io/TimeSeries.jl/dev)
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaStats.github.io/TimeSeries.jl/stable)

[![Build Status](https://github.com/JuliaStats/TimeSeries.jl/workflows/CI/badge.svg)](https://github.com/JuliaStats/TimeSeries.jl/actions?query=workflow%3ACI)
[![Coverage Status](https://codecov.io/gh/JuliaStats/TimeSeries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaStats/TimeSeries.jl)

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)

TimeSeries aims to provide a lightweight framework for working with time series data in Julia.
Documentation is provided [here](http://juliastats.github.io/TimeSeries.jl/latest/).

## Installation

Assuming that you already have Julia correctly installed, it suffices to import TimeSeries.jl in the standard way:

```julia
using Pkg
Pkg.add("TimeSeries")
```

## Examples

```julia
using TimeSeries
using Dates

dates = Date(2018, 1, 1):Day(1):Date(2018, 12, 31)
ta = TimeArray(dates, rand(length(dates)))

timestamps = DateTime(2018, 1, 1):Hour(1):DateTime(2018, 12, 31)
ta = TimeArray(timestamps, rand(length(timestamps)))
```
