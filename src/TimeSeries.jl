using  DataFrames, Calendar

module TimeSeries

using  DataFrames, Calendar

export moving, 
       lag,  
       lead,
       log_return, 
       simple_return, 
       equity, 
       upto, 
       indexyear,
       indexmonth,
       indexday,
       indexdow,
       indexhour,
       indexminute,
       indexsecond,
       indexweek,
       indexdoy,
# mutate DataFrame versions
       moving!,
       lag!,
       lead!,
       log_return!,
       simple_return!,
       equity!,
       upto!,
## aliases
       lip, 
       lips, 
       sip, 
       sips, 
## testing
       @timeseries,
       read_csv_for_testing

################## START TIMESTAMP FILES #####################

include("ImmutableTimeSeries/TimeStamps.jl")

##################### Constructor for Array{TimeStamp} ##############################
# 
# function TimeStampArray(d::DataFrame, t::Int, v::Int)
#  ts = [TimeStamp(d[1,t], d[1,v])]
#  for i in 2:nrow(d)
#   val = TimeStamp(d[i,t], d[i,v])
#   ts = push!(ts, val)
#  end
#  ts
# end
# TimeStampArray(d::DataFrame, v::Int) = TimeStampArray(d::DataFrame, 1, v::Int)  
# 
################## END TIMESTAMP FILES #####################

include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testtimeseries.jl")

end  #of module
