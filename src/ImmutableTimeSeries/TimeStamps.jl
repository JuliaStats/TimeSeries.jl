module TimeStamps

using Calendar

import Base.show
import Base.mean, Base.diff, Base.add, Base.std, Stats.skewness, Stats.kurtosis

abstract AbstractTimeStamp

immutable TimeStamp{T} <: AbstractTimeStamp
  timestamp::CalendarTime # possible improvements with Int64
  value::T
end

########### TEMPORARILY HERE, MOVE TO TRADINGINSTRUMENT 

abstract AbstractImmutablePriceData

immutable OHLC <: AbstractImmutablePriceData
  Open::Float64
  High::Float64
  Low::Float64
  Close::Float64
end

immutable OHLCVA <: AbstractImmutablePriceData
  Open::Float64
  High::Float64
  Low::Float64
  Close::Float64
  Volume::Int64
  Adj::Float64
end

########### END TEMPORARILY HERE, MOVE TO TRADINGINSTRUMENT 
 
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
       v,    #shortcut notation for v.value in v for x
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
       t,    #shortcut notation for t.timestamp in t for x
       p,    #shortcut notation for passing in CalendarTime 
       timetrial

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

function show(io::IO, oh::OHLCVA)
  print(io, oh.Open, "  ", 
            oh.High, "  ", 
            oh.Low, "  ", 
            oh.Close, "  ", 
            oh.Volume, "  ", 
            oh.Adj, "  ") 
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

######################### belongs in TradingInstrument
######################### belongs in TradingInstrument
######################### belongs in TradingInstrument

# gah, I'm too lazy to figure out the generalized version

vopen(x) = [v.value.Open for v in x]
vhigh(x) = [v.value.High for v in x]
vlow(x) = [v.value.Low for v in x]
vclose(x) = [v.value.Close for v in x]
vvolume(x) = [v.value.Volume for v in x]
vadj(x) = [v.value.Adj for v in x]

# alias trick 

const Op = vopen
const Hi = vhigh
const Lo = vlow
const Cl = vclose
const Vo = vvolume
const Ad = vadj

v(x) = [v.value for v in x]
t(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)

function iyahoo(stock::String, fm::Int, fd::Int, fy::Int, tm::Int, td::Int, ty::Int, period::String)

# take care of yahoo's 0 indexing for month
  fm-=1
  tm-=1

  ydata = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=$stock&a=$fm&b=$fd&c=$fy&d=$tm&e=$td&f=$ty&g=$period"`)
  val_string = ydata[2:end]

  sa  = split(val_string[1], ",")'
  for i in 2:length(val_string) 
    sa  = [sa ; split(val_string[i], ",")']
  end

  time_array   = Calendar.parse("yyyy-MM-dd", sa[:,1])
  open_array   = float(sa[:,2])
  high_array   = float(sa[:,3])
  low_array    = float(sa[:,4])
  close_array  = float(sa[:,5])
  volume_array = int(sa[:,6])
  adj_array    = float(sa[:,7])

  ohlcva = [OHLCVA(open_array[1],
                  high_array[1],
                  low_array[1],
                  close_array[1],
                  volume_array[1],
                  adj_array[1])]

  for i in 2:length(open_array)
    next_ohlcva = OHLCVA(open_array[i],
                  high_array[i],
                  low_array[i],
                  close_array[i],
                  volume_array[i],
                  adj_array[i])
    push!(ohlcva, next_ohlcva)
  end
  ohlcva 
  
  im = [TimeStamp(time_array[1], ohlcva[1])]
  for i in 2:length(time_array) 
    im_next = TimeStamp(time_array[i], ohlcva[i]) 
    push!(im, im_next)
  end
  flipud(im)
end

function ifred(econdata::String)
  fdata = readlines(`curl -s "http://research.stlouisfed.org/fred2/series/$econdata/downloaddata/$econdata.csv"`)
 
  # pre-process columns 
  all_val = fdata[2:end] # all the column values including Date
  vals = map(x -> split(x, ","), all_val) # split each single row string into strings split on , 
 
  # separate the two columns out
  timestamps = map(x -> x[:][1], vals) # take only the first column of values for time
  pre_values = map(x -> x[:][2], vals)  # take only the second column of values 
 
  # account for missing values
  vals = map(x -> x == "" || x == ".\r\n" ? (x = NaN) : (x = float(x)), pre_values) #TODO clean this mess up
#  vals = map(x -> x == "" ? (x = NaN) : (x = float(x)), pre_values) #TODO clean this mess up
 
  #construct the Array{TimeStamp}
   ts = [TimeStamp(Calendar.parse("yyyy-MM-dd", timestamps[1]), float(vals[1]))]
   for i in 2:length(timestamps)
     obj = TimeStamp(Calendar.parse("yyyy-MM-dd", timestamps[i]), float(vals[i]))
     ts  = push!(ts, obj)
   end
   ts
end

###########################################################
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

end #module
