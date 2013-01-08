require("DataFrames", "Calendar", "UTF16")

module Thyme

using DataFrames, Calendar, UTF16 

import DataFrames, Calendar, UTF16

require("Thyme/src/read_stock.jl")
require("Thyme/src/moving.jl")
require("Thyme/src/lead_lag.jl")
require("Thyme/src/returns.jl")
require("Thyme/src/saute.jl")

export read_stock,
       moving, moving!, 
       lead, lead!, lag, lag!, 
       log_return, log_return!, simple_return, simple_return!, equity, equity!, 
       @taste, @smell 

end 
