using  DataFrames, DataArrays, Datetime

module TimeSeries

using  DataFrames, DataArrays, Datetime

export readtime, readtime1, 
       moving, moving!,
       lag, lead, lag!, lead!,
       percentchange, percentchange!,
       upto, upto!,
       byyear, bymonth, byday, bydow, byhour, byminute, bysecond, byweek, bydoy,
       from, to, between, only, collapse,
       pad,
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
Base.@deprecate simple_return percentchange
Base.@deprecate log_return percentchange
Base.@deprecate simple_return! percentchange!
Base.@deprecate log_return! percentchange!

end  #of module
