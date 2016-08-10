using FactCheck
using TimeSeries
using Base.Dates

include("timearray.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("modify.jl")
include("meta.jl")
include("readwrite.jl")
include("timeseriesrc.jl")
include("deprecated.jl")

exitstatus()
