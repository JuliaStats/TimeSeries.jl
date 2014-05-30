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
<<<<<<< HEAD
=======

<<<<<<< HEAD
###### customizable show ########

const DECIMALS = 2
const SHOWINT = false
>>>>>>> 58502e9... trouble shooting travis fail

=======
>>>>>>> 0f2bc35... reverting to organizing const values in rc file with tests passing locally
###### include ##################

include("rc.jl")
include("tatype.jl")
include("split.jl") 
include("apply.jl")
include("combine.jl")
include("readwrite.jl")

end
