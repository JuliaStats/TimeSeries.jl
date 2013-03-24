# nan ignoring methods

function nanmax(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  max(newa)
end
function nanmin(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  min(newa)
end
function nanmean(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  mean(newa)
end
function nanmean(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  var(newa)
end
function nanstd(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  std(newa)
end
function nanmedian(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  median(newa)
end
function nanskewness(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  skewness(newa)
end
function nankurtosis(x::Array)
  newa = typeof(x[1])[]
  for i in 1:length(x)
    if x[i] < Inf
      push!(newa, x[i])
    end
  end
  kurtosis(newa)
end


#######################################
#######################################
#######################################
#######################################
#######################################

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
