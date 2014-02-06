using Datetime

module TimeArrays

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./  
       # .>, .<, .>=, .<=, .==                  # element-wise comparison on date should return BitArray 
       # +, -, *, /                             # possible semantic is concat operations? non consistent with Julian arrays
       # >, <, >=, <=, ==                       # should not be supported
       # timestamp, values, colnames,           # extracts TimeArray elements as single object of its type 
       # lag, lead,                             # returns a TimeVector
       # percentchange,                         # returns a TimeVector, kwargs simple, log 
       # moving, upto,                          # returns a TimeVector 
       # fastmoving,                            # experimental mapping algorithm
       # byyear, bymonth, byday, bydow, bydoy,  # convenience methods
       # from, to, collapse                     # subsetting and squishing
       # head, tail,                            # R or Haskell semantics? leaning towards Haskell 
       # istrue, when                           # seriespair holdovers, not sure if still useful



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
