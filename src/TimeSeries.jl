module TimeSeries

using  DataFrames, Calendar

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
       first, 
       last, 
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
       sum,
       subtract,
       spread,
# deal with NaN as if they were NAs
       removeNaN,
       removeNaN_sum,
       doremoveNaN_sum,
# other experimental methods
       convert_to_typed_array,
       ctta, # alias for convert_to_typed_array
       TimeStampArray,  #constructor of Array{TimeStamp} from DataFrame
       imfred,
       v,    #shortcut notation for v.value in v for x
       timetrial,
## testing
       @timeseries,
       read_csv_for_testing

include("reader.jl")
include("timestamp.jl")
include("timearray.jl")
include("timeframe.jl")
include("methodTime.jl")
include("operators.jl")
include("nan.jl")
# include("showTime.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testtimeseries.jl")

end  #of module
