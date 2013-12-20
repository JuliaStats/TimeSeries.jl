######## log #################################

function log_return(dv::DataArray)
  ret = diff(log(dv))
  [0 ; ret]
end
function log_return(fa::Array{Float64, 1})
  ret = diff(log(fa))
  [0 ; ret]
end
function log_return!(df::DataFrame, col::String)
  new_col = string(string(col), "_ret")
  within!(df, quote
         $new_col  = $log_return($df[$col])
        end)
end

######## simple ##############################

function simple_return(dv::DataArray)
  expm1(log_return(dv)) 
end

function simple_return(fa::Array{Float64, 1})
  expm1(log_return(fa)) 
end


function simple_return!(df::DataFrame, col::String)
  new_col = string(string(col), "_RET")
  within!(df, quote
         $new_col  = $simple_return($df[$col])
        end)
end

######## equity curve ########################

function equity(dv::DataArray)
  #padNA([expm1(cumsum(diff(log(dv)))) + 1], 1, 0)
  pad([expm1(cumsum(diff(log(dv)))) + 1], 1, 0, 1.0)
end

function equity!(df::DataFrame, col::String)
  new_col = string(string(col), "_equity")
  within!(df, quote
          $new_col  = $equity($df[$col])
          end)
end
