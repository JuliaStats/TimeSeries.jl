module TimeStamps

using Calendar
using Stats

import Base.show, Base.mean, Base.diff, Base.add, Base.std

abstract AbstractTimeStamp

immutable TimeStamp{T} <: AbstractTimeStamp
  timestamp::CalendarTime # possible improvements with Int64
  value::T
end
 
export TimeStamp, OHLC, OHLCVA,
       head, tail, first, last, 
       val, stamp, p,
       maxrows, minrows, gtrows, ltrows, etrows, 
       byyear, bymonth, byday, byhour, byminute, bysecond, byweek, bydayofweek, bydayofyear,
       diff, sum, subtract, spread,
       nanmax, nanmin, nansum, nanmean, nanmedian, nanvar, nanstd, nanskewness, nankurtosis, removeNaN, removeNaN_sum, doremoveNaN_sum,
       timetrial,
       TimeStampArray,  #constructor of Array{TimeStamp} from DataFrame
       ifred, iyahoo,
       vopen, vhigh, vlow, vclose, vvolume, vadj, Op, Hi, Lo, Cl, Vo, Ad,
       log_return 

#################################
###### Start methods ############
#################################

#################################
###### head, tail ###############
#################################

head{T<:TimeStamp}(x::Array{T}, n::Int) = x[1:n]
head{T<:TimeStamp}(x::Array{T}) = head(x, 6)
first{T<:TimeStamp}(x::Array{T}) = head(x, 1)

tail{T<:TimeStamp}(x::Array{T}, n::Int) = x[length(x)-n+1:end]
tail{T<:TimeStamp}(x::Array{T}) = tail(x, 6)
last{T<:TimeStamp}(x::Array{T}) = tail(x, 1)
 
#################################
###### Subset by operator #######
#################################

#maxx(x::Array{TimeStamp{T},1}) = x[max([v.value for v in x]) .== [v.value for v in x]]

for(nam, func) = ((:maxrows, :max), (:minrows, :min))
  @eval begin
    function ($nam){T<:TimeStamp}(x::Array{T})
      m = ($func)([v.value for v in x])
      p = int[]
      for i in 1:length(x)
        if x[i].value == m
        push!(p, i)
      end
    end
    x[p]
    end
  end
end

for(nam, func) = ((:gtrows, :>), (:ltrows, :<), (:etrows, :(==)))
  @eval begin
    function ($nam){T<:TimeStamp}(x::Array{T}, n::Union(Int, Float64))
      p = Int[]
      for i in 1:length(x)
        if x[i].value($func)n
        push!(p, i)
        end
      end
    x[p]
    end
  end
end
  
#################################
###### Time period ##############
#################################
for(nam, f) = ((:byyear, :year), 
               (:bymonth, :month), 
               (:byday, :day),
               (:byhour, :hour), 
               (:byminute, :minute),
               (:bysecond, :second), 
               (:byweek, :week),
               (:bydayofweek, :dayofweek), 
               (:bydayofyear, :dayofyear))

  @eval begin
    function ($nam){T<:TimeStamp}(x::Array{T}, t::Int)
      p = Int[]
      for i in 1:length(x)
      if ($f)(x[i].timestamp) == t
       push!(p, i)
      end
      end
      x[p]
    end
  end
end

#################################
###### 2-Array operation ########
#################################

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

#################################
###### show #####################
#################################

function show(io::IO, t::CalendarTime)
  s = format("yyyy-MM-dd", t)
  print(io, s)
end

function show(io::IO, ts::TimeStamp) 
  print(io, ts.timestamp, "  |  ", ts.value)
end

#################################
###### Comprehensions ###########
#################################

# function v(x::Array{TimeStamp}, s::String) 
#   nest = string("v.value.", s)
#   arr  = [nest for v in x]
# end

val(x) = [v.value for v in x]
stamp(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)

#################################
###### NaN ######################
#################################

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


#################################
###### include ##################
#################################

include("tradinginstrument.jl")

end #module

