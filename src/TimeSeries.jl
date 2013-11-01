using  DataFrames, Datetime

module TimeSeries

using  DataFrames, Datetime

export read_time, 
       moving,  
       lag,  
       lead,
       log_return, 
       simple_return, 
       equity, 
       upto, 
       byyear,
       bymonth,
       byday,
       bydow,
       byhour,
       byminute,
       bysecond,
       byweek,
       bydoy,
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
       @timeseries

################## include files #####################

include("io.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("bydate.jl")
include("testtimeseries.jl")

end  #of module
