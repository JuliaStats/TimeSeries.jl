import Base.show
import Base.repl_show

#################### TimeStamp #########################################

abstract AbstractTimeStamp

immutable TimeStamp <: AbstractTimeStamp
  timestamp::CalendarTime
  value::Any
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

