########## lead ########################

function lead{T<:Union(Real, String)}(v::Array{T, 1}, n::Integer)
  [v[i] = v[i+n]  for i=1:length(v)-n]
end

function lead{T<:Union(Real, String)}(dv::DataArray{T, 1}, n::Integer)
  if typeof(dv) == DataArray{Float64,1}
    leader = nas(DataVector[1.], length(dv)) 
  else
    leader = nas(DataVector[1], length(dv)) 
  end
  [leader[i] = dv[i+n]  for i=1:length(dv)-n]
  leader
end

function lead!(df::DataFrame, col::ASCIIString, n::Integer)
  new_col = strcat( string(col), "_lead_", string(n))
  within!(df, quote
         $new_col  = $lead($df[$col], $n)
        end);
end

########## lag #########################

function lag(x::DataArray, n::Int64)
  if typeof(x) == DataArray{Float64,1}
    laggard = nas(DataVector[1.], length(x)) 
  else
    laggard = nas(DataVector[1], length(x)) 
  end
  [laggard[i] = x[i-n]  for i=(n+1):length(x)]
  laggard
end

function lag!(df::DataFrame, col::ASCIIString, n::Int64)
  new_col = strcat( string(col), "_lag_", string(n))
  within!(df, quote
         $new_col  = $lag($df[$col], $n)
        end);
end
