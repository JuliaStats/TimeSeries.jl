__precompile__(true)

module TimeSeries

using Base.Dates

using RecipesBase

export TimeArray, AbstractTimeSeries,
       when, from, to, findwhen, find, timestamp, values, colnames, meta, head, tail,
       lag, lead, diff, percentchange, moving, upto,
       uniformspaced, uniformspace, dropnan,
       basecall,
       merge, collapse,
       readtimearray, writetimearray,
       update, rename

###### include ##################

include(".timeseriesrc.jl")
include("timearray.jl")
include("split.jl")
include("apply.jl")
include("broadcast.jl")
include("combine.jl")
include("readwrite.jl")
include("utilities.jl")
include("modify.jl")
include("basemisc.jl")
include("deprecated.jl")
include("Base.Dates.jl")
include("plotrecipes.jl")

end  # module TimeSeries
