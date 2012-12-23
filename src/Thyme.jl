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

export read_stock 

### function read_stock(x)
### 
### stock_df = read_table(x);
###   time_coversion = map(x -> parse("yyyy-MM-dd", x), 
###            convert(Array{UTF16String},  
###                   vector(stock_df[:,1])))
###   within!(stock_df, quote
###          Date = $(time_coversion)
###          end);
###   flipud(stock_df)
### end

function foo()
  println("you can't see me")
end


end # of module
