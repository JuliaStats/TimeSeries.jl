using DataFrames, Calendar, UTF16 

module Thyme

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
       @thyme

include("read.jl")
include("moving.jl")
include("lag.jl")
include("returns.jl")
include("upto.jl")
include("indexdate.jl")
include("testthyme.jl")

end 
