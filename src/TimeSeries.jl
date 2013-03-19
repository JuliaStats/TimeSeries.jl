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
## methods for immutable Array
       head,
       tail, 
       mean,
       std, 
       min, 
       max, 
       maxrows, 
       minrows, 
       gtrows, 
       ltrows, 
       etrows, 
## index immutable Array by time
       yearrows,
       monthrows,
       dayrows,
       dowrows,
       hourrows,
       minuterows,
       secondrows,
       weekrows,
       doyrows,
       df_to_ts, 
# other experimental methods
       convert_to_typed_array,
## testing
       @timeseries,
       read_csv_for_testing

include("timestamp.jl")
include("timearray.jl")
include("timeframe.jl")
include("methodTime.jl")
#include("showTime.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testtimeseries.jl")

end 
