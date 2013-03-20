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
       heads,
       tails, 
       mean,
       std, 
       skewness, 
       kurtosis, 
       min, 
       max, 
       maxfast, 
       maxrows, 
       maxx, 
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
# create new Array{TimeStamp} by operating on two 
       diff,
       add,
       subtract,
       spread,
# other experimental methods
       convert_to_typed_array,
       ctta, # alias for convert_to_typed_array
       TimeStampArray,  #constructor of Array{TimeStamp} from DataFrame
       timetrial,
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

end  #of module
