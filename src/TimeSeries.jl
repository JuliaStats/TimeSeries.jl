"""
    TimeSeries

A Julia package for working with time series data.

The `TimeSeries` package provides the `TimeArray` type and associated methods for handling
time-indexed data. It supports operations like filtering, transforming, combining, and
resampling time series data.

# Main Types

  - `TimeArray`: The primary time series container
  - `AbstractTimeSeries`: Abstract supertype for time series types

# Key Functions

  - Indexing and filtering: `when`, `from`, `to`, `findwhen`, `head`, `tail`
  - Transformations: `lag`, `lead`, `diff`, `percentchange`, `moving`, `upto`
  - Combining: `merge`, `collapse`, `vcat`, `hcat`
  - Resampling: `retime` with various interpolation and aggregation methods
  - I/O: `readtimearray`, `writetimearray`
  - Utilities: `timestamp`, `values`, `colnames`, `meta`

# Examples

```julia
using TimeSeries, Dates

# Create a TimeArray
dates = Date(2020,1,1):Day(1):Date(2020,1,10)
ta = TimeArray(dates, rand(10), [:Value])

# Filter by date range
ta_subset = from(ta, Date(2020,1,5))

# Calculate moving average
ta_ma = moving(mean, ta, 3)

# Resample to weekly
ta_weekly = retime(ta, Week(1))
```
"""
module TimeSeries

# stdlib
using Dates
using DelimitedFiles
using Statistics
# third-party
using DocStringExtensions: SIGNATURES
using RecipesBase
using Reexport
using Tables
using PrettyTables: PrettyTables, pretty_table

export TimeArray,
    AbstractTimeSeries,
    when,
    from,
    to,
    findwhen,
    timestamp,
    values,
    colnames,
    meta,
    head,
    tail,
    lag,
    lead,
    diff,
    percentchange,
    moving,
    upto,
    uniformspaced,
    uniformspace,
    dropnan,
    basecall,
    merge,
    collapse,
    readtimearray,
    writetimearray,
    retime,
    Linear,
    Previous,
    Next,
    Nearest,
    Mean,
    Min,
    Max,
    Count,
    Sum,
    Median,
    First,
    Last,
    FillConstant,
    NearestExtrapolate,
    MissingExtrapolate,
    NaNExtrapolate

# modify.jl
export rename, rename!

@reexport using Dates

###### include ##################

include(".timeseriesrc.jl")
include("timearray.jl")
include("utilities.jl")
include("tables.jl")
include("split.jl")
include("apply.jl")
include("broadcast.jl")
include("combine.jl")
include("readwrite.jl")
include("modify.jl")
include("basemisc.jl")
include("deprecated.jl")
include("plotrecipes.jl")
include("retime.jl")

end  # module TimeSeries
