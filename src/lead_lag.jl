########## lead ########################

function leads(v,n)
  w = v[n+1:end]
end

function lags(v,n)
  w = v[1:length(v)-n]
end

function lead{T<:Union(Real, String)}(v::Array{T, 1}, n::Integer)
  #lead_v = [v[i] = v[i+n]  for i=1:length(v)-n]
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
end

function lead!(df::DataFrame, col::ASCIIString, n::Integer)
  new_col = strcat( string(col), "_lead_", string(n))
  within!(df, quote
         $new_col  = $lead($df[$col], $n)
        end);
end

#function lead{T<:Union(Real, String)}(dv::DataArray{T, 1}, 1) = function lead{T<:Union(Real, String)}(dv::DataArray{T, 1}, n::Integer)

########## lag #########################

function lag{T<:Union(Real, String)}(v::Array{T, 1}, n::Integer)
  #[v[1] = v[i-n]  for i=(n+1):length(v)]
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
