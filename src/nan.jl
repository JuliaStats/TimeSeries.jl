function removeNaN(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] <= max(x)
      push!(newa, x[i])
    end
  end
  newa
end
function removeNaN_sum(x::Array)      
  newa = typeof(x[1])[]
    for i in 1:length(x)
      if x[i] <= max(x)
       push!(newa, x[i])
       end
    end
  sum(newa)
end
function doremoveNaN_sum(x::Array)
  sum(x) do x  
    isnan(x) ? 0 : x  
  end
end
