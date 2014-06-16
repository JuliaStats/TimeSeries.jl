using Dates

module TimeSeries

using Dates

export TimeArray, AbstractTimeSeries,
       by, from, to, findwhen, findall, timestamp, values, colnames, 
       lag, lead, percentchange, moving, upto,
       basecall,
       merge, collapse,
       readtimearray

###### include ##################

include(".timeseriesrc.jl")
include("tatype.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")

end
