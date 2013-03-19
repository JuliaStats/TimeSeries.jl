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
