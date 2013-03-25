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

function show(io::IO, oh::OHLCVA)
  print(io, oh.Open, "  ", 
            oh.High, "  ", 
            oh.Low, "  ", 
            oh.Close, "  ", 
            oh.Volume, "  ", 
            oh.Adj, "  ") 
end

################ log_return for TimeStamp OHLCVA #############

function log_return(ts::Array{TimeStamp{OHLCVA}, 1})
  res = TimeStamp[]
  push!(res, TimeStamp(ts[1].timestamp, 0.))
  for i in 2:length(ts)
    p0 = ts[i-1]
    p  = ts[i]
    stamp = p.timestamp
    ret   =  float(log(p.value.Close) - log(p0.value.Close))
    push!(res, TimeStamp(stamp, ret))
  end
  res
end

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
