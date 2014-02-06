using Datetime

module TimeArrays

using Datetime

export TimeArray, 
       readtimearray,
       .+, .-, .*, ./  #, .>, .<, .>=, .<=, .== # I think these should return Bool

#################################
###### include ##################
#################################

# include("io.jl")
# include("operators.jl")
# include("timearray.jl")
# include("timestamp.jl")
# include("transformations.jl")
# include("utilities.jl")

#################################
###### NEED TO MOVE FROM HERE ###
#################################

# for some very odd reason I need this in the TimeArray.jl file

immutable TimeArray{T,N}

   timestamp::Vector{Date{ISOCalendar}}
   values::Array{T,N}
   colnames::Vector{ASCIIString}


  function TimeArray(timestamp::Vector{Date{ISOCalendar}}, values::Array{T,N}, colnames::Vector{ASCIIString})
    nrow, ncol = size(values, 1), size(values, 2)
    nrow != size(timestamp, 1) ? error("values must match length of timestamp"):
    ncol != size(colnames,1) ? error("column names must match width of array"):
    timestamp != unique(timestamp) ? error("there are duplicate dates"):
    ~(flipud(timestamp) == sort(timestamp) || timestamp == sort(timestamp)) ? error("dates are mangled"):
    flipud(timestamp) == sort(timestamp) ? 
    new(flipud(timestamp), flipud(values), colnames):
    new(timestamp, values, colnames)
  end
end

TimeArray{T,N}(d::Vector{Date{ISOCalendar}}, v::Array{T,N}, c::Vector{ASCIIString}) = TimeArray{T,N}(d,v,c)

# from single values
function TimeArray{T,N}(d::Date{ISOCalendar}, v::Array{T,N}, c::Array{ASCIIString,1})
  TimeArray([d], v, c)
end

#################################
###### length ###################
#################################

function Base.length(ta::TimeArray)
  length(ta.timestamp)
end

#################################
###### show #####################
#################################
 
function Base.show(io::IO, ta::TimeArray)
  # variables 
  nrow       = size(ta.values, 1)
  ncol       = size(ta.values, 2)
  spacetime  = strwidth(string(ta.timestamp[1]))

  # summary line
  print(@sprintf "%dx%d %s %s to %s" nrow ncol typeof(ta) string(ta.timestamp[1]) string(ta.timestamp[nrow]))
  println("")
  println("")

  # row label line
  firstcolwidth = strwidth(ta.colnames[1])
  print(io, ^(" ", spacetime+3), ta.colnames[1], ^(" ", maxcolwidth(ta.values[:,1]) + 2 -firstcolwidth))
  for p in 2:length(ta.colnames)
    nextcolwidth = strwidth(ta.colnames[p])
    print(io, ta.colnames[p], ^(" ", maxcolwidth(ta.values[:,p]) + 2 - nextcolwidth))
  end
  println("")

  # timestamp and values line
  if nrow > 7
    for i in 1:4
      println(io, ta.timestamp[i], " | ", join([@sprintf("%.2f", t) for t in ta.values[i,:]], "  "))
    end
    println("...")
    for j in nrow-4:nrow
      println(io, ta.timestamp[j], " | ", join([@sprintf("%.2f", t) for t in ta.values[j,:]], "  "))
    end
  else
    for k in 1:nrow
      println(io, ta.timestamp[k], " | ", join([@sprintf("%.2f", t) for t in ta.values[k,:]], "  "))
    end
  end
end

function maxcolwidth(x)
  val = maximum(x)
  strwidth(@sprintf("%.2f", val))
end

#################################
###### getindex #################
#################################

# single row
function Base.getindex{T,N}(ta::TimeArray{T,N}, n::Int)
  TimeArray(ta.timestamp[n], ta.values[n, 1:end], ta.colnames)
end

# range of rows
function Base.getindex{T,N}(ta::TimeArray{T,N}, r::Range1{Int})
  TimeArray(ta.timestamp[r], ta.values[r,:], ta.colnames)
end

# array of rows
function Base.getindex{T,N}(ta::TimeArray{T,N}, a::Array{Int})
  TimeArray(ta.timestamp[a], ta.values[a,:], ta.colnames)
end

# single column by name 
function Base.getindex{T,N}(ta::TimeArray{T,N}, s::ASCIIString)
  n = findfirst(ta.colnames, s)
  TimeArray(ta.timestamp, ta.values[:, n], ASCIIString[s])
end

# array of columns by name
function Base.getindex{T,N}(ta::TimeArray{T,N}, args::ASCIIString...)
  ns = [findfirst(ta.colnames, a) for a in args]
  TimeArray(ta.timestamp, ta.values[:,ns], ASCIIString[a for a in args])
end

# single date
function Base.getindex{T,N}(ta::TimeArray{T,N}, d::Date{ISOCalendar})
   for i in 1:length(ta)
     if [d] == ta[i].timestamp 
       return ta[i] 
     else 
       nothing
     end
   end
 end
 
# range of dates
function Base.getindex{T,N}(ta::TimeArray{T,N}, dates::Array{Date{ISOCalendar},1})
  counter = Int[]
  for i in 1:length(ta)
    for j in 1:size(dates,1)
      if ta[i].timestamp == [dates[j]]
        push!(counter, i)
      end
    end
  end
  ta[counter]
 end

function Base.getindex{T,N}(ta::TimeArray{T,N}, r::DateRange{ISOCalendar}) 
  ta[[r]]
end

# day of week
# Base.getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]

#################################
###### reader ###################
#################################

function readtimearray(fname::String)
  blob    = readcsv(fname)
  tstamps = Date{ISOCalendar}[date(i) for i in blob[2:end, 1]]
  vals    = float(blob[2:end, 2:end])
  cnames  = ASCIIString[]
  for b in blob[1, 2:end]
    push!(cnames, b)
  end
  TimeArray(tstamps, vals, cnames)
end

#################################
###### +, -, *, / ###############
#################################
 
# element-wise operations between two columns
#for op in [:.+, :.-, :.*, :./, :.>, :.<, :.>=, :.<=, :.==] # return Bools for comparison operators?
for op in [:.+, :.-, :.*, :./]
  @eval begin
    #function ($op){T}(ta1::TimeArray{T,1}, ta2::TimeArray{T,1})
    function ($op){T}(ta1::TimeArray{T}, ta2::TimeArray{T})
    #function ($op){T}(ta1, ta2)
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      tstamp = Date{ISOCalendar}[]
      vals   = T[]
      for i in 1:size(ta1.timestamp, 1)
        for j in 1:size(ta2.timestamp, 1)
          if ta1.timestamp[i] == ta2.timestamp[j] 
            push!(tstamp, ta1.timestamp[i]) 
            push!(vals, ($op)(ta1.values[i], ta2.values[j])) 
          end
        end
      end
      TimeArray(tstamp, vals, cname)
    end # function
  end # eval
end # loop

end
