using Datetime

module TimeArrays

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./  #, .>, .<, .>=, .<=, .== # I think these should return Bool

#################################
###### include ##################
#################################

include("io.jl")
include("timearray.jl")
include("timestamp.jl")
include("transformations.jl")
include("utilities.jl")

end
