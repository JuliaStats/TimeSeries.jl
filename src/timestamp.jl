import Base.show

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

