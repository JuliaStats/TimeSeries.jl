import Base.show
import Base.repl_show
import Base.mean

#################### TimeStamp #########################################

abstract AbstractTimeStamp

immutable TimeStamp <: AbstractTimeStamp
  timestamp::CalendarTime
  value
end

###################### show methods #################################

function show(io::IO, t::CalendarTime)
  s = format("yyyy-MM-dd", t)
  print(io, s)
end

function show(io::IO, ts::TimeStamp) 
  print(io, ts.timestamp, "  \u1409  ", ts.value)
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

###################### simple maths methods #################################

# elapsed time for GSPC.csv file is 0.017835577 (first run)
function mean(x::Array{TimeStamp}) 
  r = length(x)
  s = 0 
  for v in x
    s += v.value
  end
  s/r
end


# elapsed time for GSPC.csv file is 0.142614052 (first run)
#mean(x::Array{TimeStamp}) = mean([v.value for v in x])
