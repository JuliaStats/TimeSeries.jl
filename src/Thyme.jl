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
require("Thyme/src/moving_bang.jl")

export read_stock, equity_curve,
       moving, moving!, 
       @taste, recipe

const recipe = "read_stock"

macro taste(ex::Symbol)
  #if :($ex) == :($recipe)
  #  load(strcat("~/.julia/Thyme/test/". :($recipe), ".jl"))
  #else 
    load(strcat("~/.julia/Thyme/test/", :($ex), ".jl"))
  #end
end


end 
