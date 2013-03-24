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

# removed all single value return methods
# unnecessary since Array methods suffice

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
