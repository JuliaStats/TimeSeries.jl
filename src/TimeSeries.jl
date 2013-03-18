using Calendar, UTF16, DataFrames 

module TimeSeries

using Calendar, UTF16, DataFrames 

export TimeStamp,
       TimeArray,
       TimeFrame,
       moving, 
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
       head,
       tail, 
       mean,
       std, 
       min, 
       max, 

## testing
       @timeseries,
       read_csv_for_testing

include("timestamp.jl")
include("timearray.jl")
include("timeframe.jl")
include("time_methods.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testtimeseries.jl")

end 
