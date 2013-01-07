function lag_array(x::DataArray, n::Int64)
  if typeof(x) == DataArray{Float64,1}
    laggard = nas(DataVector[1.], length(x)) 
  else
    laggard = nas(DataVector[1], length(x)) 
  end
  [laggard[i] = x[i-n]  for i=(n+1):length(x)]
  laggard
end
