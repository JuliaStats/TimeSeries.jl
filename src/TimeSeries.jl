using Datetime

module TimeSeries

using Datetime

export TimeArray, AbstractTimeSeries,
       by, from, to, findwhen, findall, timestamp, values, colnames, 
       lag, lead, percentchange, moving, upto,                                  
       .+, .-, .*, ./, .^, +, -, *, /, 
       .>, .<, .>=, .<=, .==,  
       basecall,
       merge, collapse,                    
       readtimearray,
       DECIMALS, SHOWINT 

###### include ##################

include("rc.jl")
include("tatype.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")

end
