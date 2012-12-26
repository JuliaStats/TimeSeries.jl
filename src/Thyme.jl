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

export read_stock, @taste, recipe

const recipe = "read_stock"

macro taste(ex::Symbol)
  #if :($ex) == :($recipe)
  #  load(strcat("~/.julia/Thyme/test/". :($recipe), ".jl"))
  #else 
    load(strcat("~/.julia/Thyme/test/", :($ex), ".jl"))
  #end
end


end 
