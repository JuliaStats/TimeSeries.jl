using Datetime

module TimeArrays

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./  #, .>, .<, .>=, .<=, .== # I think these should return Bool

immutable TimeArray{T<:Real,N}

   timestamp::Vector{Date{ISOCalendar}}
   values::Array{T,N}
   colnames::Vector{ASCIIString}


  function TimeArray(timestamp::Vector{Date{ISOCalendar}}, values::Array{T,N}, colnames::Vector{ASCIIString})
    nrow, ncol = size(values, 1), size(values, 2)
    nrow != size(timestamp, 1) ? error("values must match length of timestamp"):
    ncol != size(colnames,1) ? error("column names must match width of array"):
    timestamp != unique(timestamp) ? error("there are duplicate dates"):
    ~(flipud(timestamp) == sort(timestamp) || timestamp == sort(timestamp)) ? error("dates are mangled"):
    flipud(timestamp) == sort(timestamp) ? 
    new(flipud(timestamp), flipud(values), colnames):
    new(timestamp, values, colnames)
  end
end

TimeArray{T,N}(d::Vector{Date{ISOCalendar}}, v::Array{T,N}, c::Vector{ASCIIString}) = TimeArray{T,N}(d,v,c)

#################################
###### include ##################
#################################

include("io.jl")
include("operators.jl")
include("timearray.jl")
include("timestamp.jl")
include("transformations.jl")
include("utilities.jl")

end
