using  DataFrames, DataArrays, Datetime

module TimeSeries

using  DataFrames, DataArrays, Datetime

export readtime, 
       readtime1, 
       moving,  
       lag,  
       lead,
       log_return, 
       simple_return, 
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
       from,
       to,
       between,
       only,
       collapse,
# mutate DataFrame versions
       moving!,
       lag!,
       lead!,
       log_return!,
       simple_return!,
       upto!,
## utilis
       pad,
## testing
       @timeseries

################## include files #####################

include("io.jl")
include("moving.jl")
include("lag.jl")
include("percentchange.jl")
include("upto.jl")
include("utils.jl")
include("date.jl")
include("../test/testmacro.jl")

################## deprecations #######################

Base.@deprecate read_time readtime
Base.@deprecate indexyear byyear
Base.@deprecate indexmonth bymonth
Base.@deprecate indexday byday
Base.@deprecate indexdow bydow
Base.@deprecate sip simple_return
Base.@deprecate sips simple_return!
Base.@deprecate lip log_return 
Base.@deprecate lips log_return!

end  #of module
