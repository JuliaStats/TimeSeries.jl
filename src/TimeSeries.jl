using Datetime

module TimeSeries

using Datetime

export TimeArray, 
       readtimearray, 
       .+, .-, .*, ./, .^, +, -, *, /, 
       .>, .<, .>=, .<=, .==,  
       byyear, bymonth, byday, bydow, bydoy,  
       from, to,  collapse,                    
       lag, lead, percentchange, upto, moving,                                  
       findall, findwhen, basecall

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
