########## lead ########################

function lead{T<:Union(Real, String)}(v::Array{T, 1}, n::Integer)
  w = v[n+1:end]
end

function lead{T<:Union(Real, String)}(dv::DataArray{T, 1}, n::Integer)
  if typeof(dv) == DataArray{Float64,1}
    leader = nas(DataVector[1.], length(dv)) 
  else
    leader = nas(DataVector[1], length(dv)) 
  end
  [leader[i] = dv[i+n]  for i=1:length(dv)-n]
  leader
#  [ dv[n+1:end]; NApad(n)]
end

function lead!(df::DataFrame, col::ASCIIString, n::Integer)
  new_col = strcat( string(col), "_lead_", string(n))
  within!(df, quote
         $new_col  = $lead($df[$col], $n)
        end);
end

lead(dv) = lead(dv, 1)
lead!(df, col) = lead!(df, col, 1)

########## lag #########################

function lag{T<:Union(Real, String)}(v::Array{T, 1}, n::Integer)
  w = v[1:length(v)-n]
end

function lag{T<:Union(Real, String)}(dv::DataArray{T, 1}, n::Integer)
  if typeof(dv) == DataArray{Float64,1}
    laggard = nas(DataVector[1.], length(dv)) 
  else
    laggard = nas(DataVector[1], length(dv)) 
  end
  [laggard[i] = dv[i-n]  for i=(n+1):length(dv)]
  laggard
end

function lag!(df::DataFrame, col::ASCIIString, n::Int64)
  new_col = strcat( string(col), "_lag_", string(n))
  within!(df, quote
         $new_col  = $lag($df[$col], $n)
        end);
end

lag(dv) = lag(dv, 1)
lag!(df, col) = lag!(df, col, 1)
