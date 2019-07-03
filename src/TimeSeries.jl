module TimeSeries

using Dates
using DelimitedFiles
using Statistics
using Tables

using RecipesBase
using Reexport

export TimeArray, AbstractTimeSeries,
       when, from, to, findwhen, find, timestamp, values, colnames, meta, head, tail,
       lag, lead, diff, percentchange, moving, upto,
       uniformspaced, uniformspace, dropnan,
       basecall,
       merge, collapse,
       readtimearray, writetimearray,
       update, rename, rename!

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
