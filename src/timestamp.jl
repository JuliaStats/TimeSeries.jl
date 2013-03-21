# importall Base #this is sneaky and ruins Calendar

import Base.show
import Base.repl_show
import Base.diff
import Base.add

#################### TimeStamp #########################################

abstract AbstractTimeStamp

immutable TimeStamp{T} <: AbstractTimeStamp
  timestamp::CalendarTime # possible improvements with Int64
  value::T
end

###################### show methods #################################

function show(io::IO, t::CalendarTime)
  s = format("yyyy-MM-dd", t)
  print(io, s)
end

function show(io::IO, ts::TimeStamp) 
  print(io, ts.timestamp, "  |  ", ts.value)
end

# function repl_show(io::IO, ts::TimeStamp) 
#   println(io, [ts.timestamp ts.value])
# end
# 
# function repl_show(io::IO, ts::Array{TimeStamp}) 
#   println(io, ts)
# end
# 
# function show(io::IO, ts::Array{TimeStamp}) 
#   for i in 1:e
#   print(io, ts[i])
#   end
# end

##################### Constructor for Array{TimeStamp} ##############################

function TimeStampArray(d::DataFrame, t::Int, v::Int)
 ts = [TimeStamp(d[1,t], d[1,v])]
 for i in 2:nrow(d)
  val = TimeStamp(d[i,t], d[i,v])
  ts = push!(ts, val)
 end
 ts
end
TimeStampArray(d::DataFrame, v::Int) = TimeStampArray(d::DataFrame, 1, v::Int)  

##################### Compare two Arrays on timestamp key ###############################
##################### Need @eval loop here, desperately! ###############################

function diff(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value - b[j].value))
      end
    end
  end
  newts
end
function add(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value + b[j].value))
      end
    end
  end
  newts
end
function subtract(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value - b[j].value))
      end
    end
  end
  newts
end
function spread(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, abs(a[i].value - b[j].value)))
      end
    end
  end
  newts
end
