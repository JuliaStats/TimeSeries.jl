import Base.show
import Base.repl_show

#################### TimeStamp #########################################

abstract AbstractTimeStamp

immutable TimeStamp <: AbstractTimeStamp
  timestamp::CalendarTime
  value
end

###################### methods #################################

function show(io::IO, t::CalendarTime)
  s = format("yyyy-MM-dd", t)
  print(io, s)
end

function show(io::IO, ts::TimeStamp) 
  println(io, [ts.timestamp ts.value])
end

function repl_show(io::IO, ts::TimeStamp) 
  println(io, [ts.timestamp ts.value])
end

function repl_show(io::IO, ts::Array{TimeStamp}) 
  println(io, ts)
end

