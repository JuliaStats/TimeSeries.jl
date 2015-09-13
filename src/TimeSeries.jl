using Base.Dates

module TimeSeries

using Base.Dates

export TimeArray, AbstractTimeSeries,
       by, from, to, findwhen, findall, timestamp, values, colnames, meta,
       lag, lead, percentchange, moving, upto,
       basecall,
       merge, collapse,
       readtimearray

###### include ##################

include(".timeseriesrc.jl")
include("timearray.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")
include("utilities.jl")

end
