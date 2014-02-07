using Datetime

module TimeSeries

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./, # .>, .<, .>=, .<=, .==  # element-wise comparison on date should return BitArray 
       # byyear, bymonth, byday, bydow, bydoy,  # convenience methods
       from, to,  collapse,                    
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
