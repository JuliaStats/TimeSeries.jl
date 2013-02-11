using DataFrames, Calendar, UTF16 

module TimeSeries

using DataFrames, Calendar, UTF16 

export read_yahoo,
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
       yip, 
       lip, 
       lips, 
       sip, 
       sips, 
## testsuite macro
       @timeseries

include("read.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testtimeseries.jl")

end 
