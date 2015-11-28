VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

using Base.Dates

module TimeSeries

using Base.Dates

export TimeArray, AbstractTimeSeries,
       when, from, to, findwhen, findall, timestamp, values, colnames, meta,
       lag, lead, percentchange, moving, upto,
       basecall,
       merge, collapse,
       readtimearray,
       # deprecated
       by

###### include ##################

include(".timeseriesrc.jl")
include("timearray.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")
include("utilities.jl")
include("deprecated.jl")

end
