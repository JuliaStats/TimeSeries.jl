require("DataFrames")
require("Calendar")
require("UTF16")

module Thyme

using DataFrames
using Calendar
using UTF16 

import DataFrames
import Calendar 
import UTF16

require("Thyme/src/read_stock.jl")
require("Thyme/src/equity_curve.jl")
require("Thyme/src/moving.jl")
require("Thyme/src/lead_lag.jl")
require("Thyme/src/saute.jl")

export read_stock, equity_curve,
       moving, moving!, 
       lead, lead!, lag, lag!, 
       @taste, @smell 

end 
