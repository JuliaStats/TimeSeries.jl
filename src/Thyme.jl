require("DataFrames", "Calendar", "UTF16")

module Thyme

using DataFrames, Calendar, UTF16 

import DataFrames, Calendar, UTF16


export read_stock,
       moving, moving!, 
       lead, lead!, lag, lag!, 
       log_return, log_return!, 
       simple_return, simple_return!, 
       equity, equity!, 
       @taste, @smell 

include(joinpath(julia_pkgdir(), "Thyme", "src", "read_stock.jl"))
include(joinpath(julia_pkgdir(), "Thyme", "src", "moving.jl"))
include(joinpath(julia_pkgdir(), "Thyme", "src", "lead_lag.jl"))
include(joinpath(julia_pkgdir(), "Thyme", "src", "returns.jl"))
include(joinpath(julia_pkgdir(), "Thyme", "src", "saute.jl"))

end 
