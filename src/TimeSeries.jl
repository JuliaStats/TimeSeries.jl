if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

module TimeSeries

if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using Compat

export TimeArray, AbstractTimeSeries,
       by, from, to, findwhen, findall, timestamp, values, colnames, 
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

end
