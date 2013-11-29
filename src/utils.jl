function pad(da::DataArray, top::Int, bottom::Int, padwith) #differs from DataArray version in that da is not AbstractDataVector (should it be?)
  [unshift!(da, padwith) for i = 1:top]
  [push!(da, padwith) for i = 1:bottom]
  return da
end
