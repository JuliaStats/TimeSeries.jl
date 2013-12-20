########## lead ########################

function lead(dv::DataArray, n::Integer)
  pad(dv[n+1:end], 0, n, NA)
end

function lead!(df::DataFrame, col::String, n::Integer)
  new_col = string( string(col), "_lead_", string(n))
  within!(df, quote
         $new_col  = $lead($df[$col], $n)
        end)
end

lead(dv) = lead(dv, 1)
lead!(df, col) = lead!(df, col, 1)

########## lag #########################

function lag(dv::DataArray, n::Integer)
  if n < 0
    lead(dv, abs(n))
  else
    #padNA( dv[1:length(dv)-n], n, 0)
    pad( dv[1:length(dv)-n], n, 0, NA)
  end
end

function lag!(df::DataFrame, col::String, n::Integer)
  new_col = string( string(col), "_lag_", string(n))
  within!(df, quote
         $new_col  = $lag($df[$col], $n)
         end)
end

lag(dv) = lag(dv, 1)
lag!(df, col) = lag!(df, col, 1)
