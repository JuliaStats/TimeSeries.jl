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
using PrettyTables: pretty_table

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
    writetimearray

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

end  # module TimeSeries
