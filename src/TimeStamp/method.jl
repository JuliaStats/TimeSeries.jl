import Base.mean
import Base.std
import Stats.skewness
import Stats.kurtosis

head{T}(x::Array{TimeStamp{T},1}, n::Int) = x[1:n]
head{T}(x::Array{TimeStamp{T},1}) = head(x, 6)
first{T}(x::Array{TimeStamp{T},1}) = head(x, 1)

tail{T}(x::Array{TimeStamp{T},1}, n::Int) = x[length(x)-n+1:end]
tail{T}(x::Array{TimeStamp{T},1}) = tail(x, 6)
last{T}(x::Array{TimeStamp{T},1}) = tail(x, 1)

#mean(x::Array{TimeStamp{T},1}) = mean([v.value for v in x])
#mean{T}(x::Array{TimeStamp{T},1}) = mean(v(x))
# std(x::Array{TimeStamp{T},1}) = std([v.value for v in x])
# skewness(x::Array{TimeStamp{T},1}) = skewness([v.value for v in x])
# kurtosis(x::Array{TimeStamp{T},1}) = kurtosis([v.value for v in x])
# 
# min(x::Array{TimeStamp{T},1}) = min([v.value for v in x])
# max(x::Array{TimeStamp{T},1}) = max([v.value for v in x])
# function maxfast(x::Array{TimeStamp{T},1}) 
#   c = ctta(x)
#  max(c)
# end

###################### initial maths methods #################################

# elapsed time for GSPC.csv file is 0.017835577 (first run)
#function mean(x::Array{TimeStamp{T},1}) 
#  s = 0 
#  for v in x
#    s += v.value
#  end
#  s/length(x)
#end

# elapsed time for GSPC.csv file is 0.142614052 (first run)
#mean(x::Array{TimeStamp{T},1}) = mean([v.value for v in x])


##################### rows that have value specified ################
#maxx(x::Array{TimeStamp{T},1}) = x[max([v.value for v in x]) .== [v.value for v in x]]

function maxrows{T}(x::Array{TimeStamp{T},1})
  m = max([v.value for v in x])
  #m = max(x) # no noticable speed impact either way
  p = Int[]
  for i in 1:length(x)
    if x[i].value == m
      push!(p, i)
    end
  end
  x[p]
end

function minrows{T}(x::Array{TimeStamp{T},1})
  m = min([v.value for v in x])
  p = Int[]
  for i in 1:length(x)
    if x[i].value == m
      push!(p, i)
    end
  end
  x[p]
end

function gtrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].value > n
      push!(p, i)
    end
  end
  x[p]
end

function ltrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].value < n
      push!(p, i)
    end
  end
  x[p]
end

function etrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
  p = Int[]
  for i in 1:length(x)
    if x[i].value == n
      push!(p, i)
    end
  end
  x[p]
end

##################### rows that have value specified for multi-element value field ################





######## duplicative time indexing ###################
######## needs refactor to an @eval loop ############

# function yearrows(x::Array{timestamp}, t::int)
#   p = Int[]
#   for i in 1:length(x)
#     if year(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function monthrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if month(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function dayrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if day(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function dowrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if dayofweek(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# ####### second batch of functions
# 
# function hourrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if hour(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# function minuterows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if minute(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# function secondrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if second(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# function weekrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if week(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# function doyrows(x::Array{TimeStamp{T},1}, t::Int)
#   p = Int[]
#   for i in 1:length(x)
#     if dayofyear(x[i].timestamp) == t
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# ### other methods of experimental nature ######################
# 
# function convert_to_typed_array(ts::Array{TimeStamp{T},1})
#   typs = typeof(ts[1].value)
#   if typs == Float64 || typs == Float32
#     float([v.value for v in ts])
#   elseif typs == Int64 || typs == Int32
#     int([v.value for v in ts])
#   end
# end
# 
# ctta(ts::Array{TimeStamp{T},1}) = convert_to_typed_array(ts::Array{TimeStamp{T},1})
