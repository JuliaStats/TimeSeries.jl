import Base.mean
import Base.std
import Stats

head(x::Array{TimeStamp}, n::Int) = x[1:n]
head(x::Array{TimeStamp}) = head(x::Array{TimeStamp}, 6)

tail(x::Array{TimeStamp}, n::Int) = x[length(x)-n:end]
tail(x::Array{TimeStamp}) = tail(x::Array{TimeStamp}, 6)

mean(x::Array{TimeStamp}) = mean([v.value for v in x])
std(x::Array{TimeStamp}) = std([v.value for v in x])
#skewness(x::Array{TimeStamp}) = skewness([v.value for v in x])
#kurtosis(x::Array{TimeStamp}) = kurtosis([v.value for v in x])

min(x::Array{TimeStamp}) = min([v.value for v in x])
max(x::Array{TimeStamp}) = max([v.value for v in x])

###################### initial maths methods #################################

# elapsed time for GSPC.csv file is 0.017835577 (first run)
#function mean(x::Array{TimeStamp}) 
#  s = 0 
#  for v in x
#    s += v.value
#  end
#  s/length(x)
#end

# elapsed time for GSPC.csv file is 0.142614052 (first run)
#mean(x::Array{TimeStamp}) = mean([v.value for v in x])


##################### rows that have value specified ################

function maxrows(x::Array{TimeStamp})
  m = max([v.val for v in x])
  p = Int[]
  for i in 1:length(x)
    if x[i].val == m
      push!(p, i)
    end
  end
  x[p]
end

function minrows(x::Array{TimeStamp})
  m = min([v.val for v in x])
  p = Int[]
  for i in 1:length(x)
    if x[i].val == m
      push!(p, i)
    end
  end
  x[p]
end

function gtrows(x::Array{TimeStamp}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].val > n
      push!(p, i)
    end
  end
  x[p]
end

function ltrows(x::Array{TimeStamp}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].val < n
      push!(p, i)
    end
  end
  x[p]
end

function etrows(x::Array{TimeStamp}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].val == n
      push!(p, i)
    end
  end
  x[p]
end
