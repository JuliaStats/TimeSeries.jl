########## lead ########################

function lead(v::Array, n::Integer)
  v[n+1:end]
end

function lead(dv::DataArray, n::Integer)
  padNA(dv[n+1:end], 0, n)
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

function lag(v::Array, n::Integer)
  if n < 0
    lead(v, abs(n))
  else
    v[1:length(v)-n]
  end
end

function lag(dv::DataArray, n::Integer)
  if n < 0
    lead(dv, abs(n))
  else
    padNA( dv[1:length(dv)-n], n, 0)
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
