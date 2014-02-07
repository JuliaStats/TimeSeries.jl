using Datetime, ArrayViews

module TimeSeries

using Datetime, ArrayViews

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./, # .>, .<, .>=, .<=, .==  # element-wise comparison on date should return BitArray 
       byyear, bymonth, byday, bydow, bydoy,  
       from, to,  collapse,                    
       lag, lead, percentchange, upto, moving,                                  
       lag1, lead1, percentchange1, upto1, moving1, # ArrayViews implementations                                 
       head, tail, timestamp, values, colnames 
       # timeit                                 # timing method

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
