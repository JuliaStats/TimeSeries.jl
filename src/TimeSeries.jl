using Datetime, ArrayViews

module TimeSeries

using Datetime, ArrayViews

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./, # .>, .<, .>=, .<=, .==  # element-wise comparison on date should return BitArray 
       # byyear, bymonth, byday, bydow, bydoy,  # convenience methods
       # from, to, collapse,                    # subsetting and squishing
       lag, lead, percentchange, upto, moving,                                  
       head, tail, timestamp, values, colnames             

#################################
###### include ##################
#################################

include("timearray.jl")
include("io.jl")
include("operators.jl") 
include("timestamp.jl")
include("transformations.jl")
include("utilities.jl")

end
