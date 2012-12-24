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

export read_stock, @taste

macro taste(ex)
  foo = strcat("~/.julia/Thyme/test/", :($ex), ".jl")
  load(foo)
end


end 
