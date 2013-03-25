module TimeStamps

using Calendar
using Stats

import Base.show, Base.mean, Base.diff, Base.add, Base.std

abstract AbstractTimeStamp

immutable TimeStamp{T} <: AbstractTimeStamp
  timestamp::CalendarTime # possible improvements with Int64
  value::T
end
 
export TimeStamp,
       OHLC,
       OHLCVA,
       head,
       tail, 
       first, 
       last, 
# use Array methods when single value desired
# use row-styled methods when the return of the entire object preferred
       maxrows, 
       minrows, 
       gtrows, 
       ltrows, 
       etrows, 
       yearrows,
       monthrows,
       dayrows,
       dowrows,
       hourrows,
       minuterows,
       secondrows,
       weekrows,
       doyrows,
# create new Array{TimeStamp} by operating on two 
       diff,
       sum,
       subtract,
       spread,
# deal with NaN as if they were NAs
       nanmax,
       nanmin,
       nansum,
       nanmean,
       nanmedian,
       nanvar,
       nanstd,
       nanskewness,
       nankurtosis,
       removeNaN,
       removeNaN_sum,
       doremoveNaN_sum,
# other experimental methods
       TimeStampArray,  #constructor of Array{TimeStamp} from DataFrame
       ifred,
       iyahoo,
       val,    #shortcut notation for v.value in v for x
       vopen,
       vhigh,
       vlow,
       vclose,
       vvolume,
       vadj,
       Op,
       Hi,
       Lo,
       Cl,
       Vo,
       Ad,
       stamp,    #shortcut notation for t.timestamp in t for x
       p,    #shortcut notation for passing in CalendarTime 
       log_return, 
       timetrial

head{T<:TimeStamp}(x::Array{T}, n::Int) = x[1:n]
head{T<:TimeStamp}(x::Array{T}) = head(x, 6)
first{T<:TimeStamp}(x::Array{T}) = head(x, 1)

tail{T<:TimeStamp}(x::Array{T}, n::Int) = x[length(x)-n+1:end]
tail{T<:TimeStamp}(x::Array{T}) = tail(x, 6)
last{T<:TimeStamp}(x::Array{T}) = tail(x, 1)

# removed all single value return methods
# unnecessary since Array methods suffice

##################### rows that have value specified ################

#maxx(x::Array{TimeStamp{T},1}) = x[max([v.value for v in x]) .== [v.value for v in x]]


for(nam, func) = ((:maxrows, :max), (:minrows, :min))
  @eval begin
    function ($nam){T}(x::Array{TimeStamp{T}, 1})
      m = ($func)([v.value for v in x])
      p = Int[]
      for i in 1:length(x)
        if x[i].value == m
        push!(p, i)
      end
    end
    x[p]
    end
  end
end

# function maxrows{T}(x::Array{TimeStamp{T},1})
#   m = max([v.value for v in x])
#   #m = max(x) # no noticable speed impact either way
#   p = Int[]
#   for i in 1:length(x)
#     if x[i].value == m
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function minrows{T}(x::Array{TimeStamp{T},1})
#   m = min([v.value for v in x])
#   p = Int[]
#   for i in 1:length(x)
#     if x[i].value == m
#       push!(p, i)
#     end
#   end
#   x[p]
# end

for(nam, func) = ((:gtrows, :>), (:ltrows, :<), (:etrows, :(==)))
  @eval begin
    function ($nam){T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
      p = Int[]
      for i in 1:length(x)
        if x[i].value ($func) n
        push!(p, i)
        end
      end
    x[p]
    end
  end
end

# function gtrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
#   p = Int[]
#   for i in 1:length(x)
#     if x[i].value > n
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function ltrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
#   p = Int[]
#   for i in 1:length(x)
#     if x[i].value < n
#       push!(p, i)
#     end
#   end
#   x[p]
# end
# 
# function etrows{T}(x::Array{TimeStamp{T},1}, n::Union(Int, Float64))
#   p = Int[]
#   for i in 1:length(x)
#     if x[i].value == n
#       push!(p, i)
#     end
#   end
#   x[p]
# end

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

##################### Compare two Arrays on timestamp key ###############################
##################### Need @eval loop here, desperately! ###############################

function diff(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value - b[j].value))
      end
    end
  end
  newts
end
function add(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value + b[j].value))
      end
    end
  end
  newts
end
function subtract(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, a[i].value - b[j].value))
      end
    end
  end
  newts
end
function spread(a::Array{TimeStamp}, b::Array{TimeStamp})
  newts = TimeStamp[]
  for i in 1:length(a)
    for j in 1:length(b)
      if a[i].timestamp == b[j].timestamp
      push!(newts, TimeStamp(a[i].timestamp, abs(a[i].value - b[j].value)))
      end
    end
  end
  newts
end

##################### SHOW ##########################

function show(io::IO, t::CalendarTime)
  s = format("yyyy-MM-dd", t)
  print(io, s)
end

function show(io::IO, ts::TimeStamp) 
  print(io, ts.timestamp, "  |  ", ts.value)
end


# function repl_show(io::IO, ts::TimeStamp) 
#   println(io, [ts.timestamp ts.value])
# end
# 
# function repl_show(io::IO, ts::Array{TimeStamp}) 
#   println(io, ts)
# end

####################### END SHOW #######################

### shortcut to extracting out the fields from Array{TimeStamp}

# function v(x::Array{TimeStamp}, s::String) 
#   nest = string("v.value.", s)
#   arr  = [nest for v in x]
# end

val(x) = [v.value for v in x]
stamp(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)
############ NaN methods ##################################

function removeNaN(x::Array)
  newa = Float64[]
  for i in 1:length(x)
    if ~isnan(x[i])
      push!(newa, x[i])
    end
  end
  newa
end

for(nam, func) = ((:nansum, :sum), (:nanmean, :mean), (:nanmedian, :median), 
                  (:nanvar, :var), (:nanstd, :std), 
                  (:nanskewness, :skewness), (:nankurtosis, :kurtosis))
  @eval begin
    function ($nam)(x::Array)
      newa = Float64[]
      for i in 1:length(x)
      if ~isnan(x[i])
        push!(newa, x[i])
      end
    end
    ($func)(newa)
    end
  end
end

############  preliminary attempts to create NaN ignoring methods
# function doremoveNaN_sum(x::Array)
#   sum(x) do x  
#     isnan(x) ? 0 : x  
#   end
# end
###########################################################
############ end NaN methods ##################################


include("tradinginstrument.jl")

end #module

