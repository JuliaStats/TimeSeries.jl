using Datetime

module TimeArrays

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./  #, .>, .<, .>=, .<=, .== # I think these should return Bool

#################################
###### include ##################
#################################

include("timearray.jl")
include("io.jl")
include("operators.jl") # intentionally called after type definition include in timearray.jl
include("timestamp.jl")
include("transformations.jl")
include("utilities.jl")

end
