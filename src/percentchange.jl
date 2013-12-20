function percentchange(dv::DataArray; method="simple")
  if method == "simple" 
    return expm1(log_return(dv))
  elseif method == "log" 
    return log_return(dv)
  else 
    throw("only simple and log methods supported")
  end
end

function percentchange!(df::DataFrame, col::String; method="simple")
  if method == "simple" 
    new_col = string(string(col), "_simplechange")
    within!(df, quote $new_col  = $percentchange($df[$col]) end)
  elseif method == "log" 
    new_col = string(string(col), "_logchange")
    within!(df, quote $new_col  = $percentchange($df[$col], method="log") end)
  else 
    throw("only simple and log methods supported")
  end
end

function log_return(dv::DataArray)
  pad(diff(log(dv)), 1, 0, NA)
end
