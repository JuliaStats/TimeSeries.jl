using Datetime

module TimeSeries

using Datetime

export TimeArray, 
       by, from, to, findwhen, findall, timestamp, values, colnames, 
       lag, lead, percentchange, moving, upto,                                  
       .+, .-, .*, ./, .^, +, -, *, /, 
       .>, .<, .>=, .<=, .==,  
       basecall,
       merge, collapse,                    
       readtimearray 

#################################
###### include ##################
#################################

include("type.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")

end
