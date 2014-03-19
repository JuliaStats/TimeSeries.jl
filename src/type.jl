###### type definition ##########

abstract AbstractTimeArray

immutable TimeArray{T,N} <: AbstractTimeArray

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

###### length ###################

Base.length(ta::TimeArray) = length(ta.timestamp)

###### iterator protocol #########

Base.start{T,N}(ta::TimeArray{T,N})   = 1
#Base.next{T,N}(ta::TimeArray{T,N},i)  = (ta[i],i+1)
#Base.next{T,N}(ta::TimeArray{T,N},i)  = (TimeArray(ta.timestamp[i],ta.values[i,:], ta.colnames),i+1)
#Base.next{T,N}(ta::TimeArray{T,N},i)  = ((ta.timestamp[i],ta.values[i]),i+1)
Base.next{T,N}(ta::TimeArray{T,N},i)  = ((ta.timestamp[i],ta.values[i,:]),i+1)
Base.done{T,N}(ta::TimeArray{T,N},i)  = (i > length(ta))
Base.isempty{T,N}(ta::TimeArray{T,N}) = (length(ta) == 0)

# Base.start(ta::TimeArray)   = 1
# Base.next(ta::TimeArray,i)  = (ta[i],i+1)
# Base.done(ta::TimeArray,i)  = (i > length(ta))
# Base.isempty(ta::TimeArray) = (length(ta) == 0)

###### show #####################
 
function Base.show(io::IO, ta::TimeArray)
  # variables 
  nrow          = size(ta.values, 1)
  ncol          = size(ta.values, 2)
  spacetime     = strwidth(string(ta.timestamp[1])) + 3
  firstcolwidth = strwidth(ta.colnames[1])
  colwidth      = Int[]
      for m in 1:ncol
          push!(colwidth, max(strwidth(ta.colnames[m]), strwidth(@sprintf("%.2f", maximum(ta.values[:,m])))))
      end

  # summary line
  print(@sprintf("%dx%d %s %s to %s", nrow, ncol, typeof(ta), string(ta.timestamp[1]), string(ta.timestamp[nrow])))
  println("")
  println("")

  # row label line

   print(io, ^(" ", spacetime), ta.colnames[1], ^(" ", colwidth[1] + 2 -firstcolwidth))

   for p in 2:length(colwidth)
     print(io, ta.colnames[p], ^(" ", colwidth[p] - strwidth(ta.colnames[p]) + 2))
   end
   println("")
 
  # timestamp and values line
    if nrow > 7
        for i in 1:4
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            print(rpad(round(ta.values[i,j], 2), colwidth[j] + 2, " "))
        end
        println("")
        end
        println('\u22EE')
        for i in nrow-3:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            print(rpad(round(ta.values[i,j], 2), colwidth[j] + 2, " "))
        end
        println("")
        end
    else
        for i in 1:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            print(rpad(round(ta.values[i,j], 2), colwidth[j] + 2, " "))
        end
        println("")
        end
    end
end

###### getindex #################

# single row
function Base.getindex{T,N}(ta::TimeArray{T,N}, n::Int)
    TimeArray(ta.timestamp[n], ta.values[n,:], ta.colnames)
end

# single row 1d
function Base.getindex{T}(ta::TimeArray{T,1}, n::Int)
    TimeArray(ta.timestamp[n], ta.values[[n]], ta.colnames)
end

# range of rows
function Base.getindex{T,N}(ta::TimeArray{T,N}, r::Range1{Int})
    TimeArray(ta.timestamp[r], ta.values[r,:], ta.colnames)
end

# range of 1d rows
function Base.getindex{T}(ta::TimeArray{T,1}, r::Range1{Int})
    TimeArray(ta.timestamp[r], ta.values[r], ta.colnames)
end

# array of rows
function Base.getindex{T,N}(ta::TimeArray{T,N}, a::Array{Int})
    TimeArray(ta.timestamp[a], ta.values[a,:], ta.colnames)
end

# array of 1d rows
function Base.getindex{T}(ta::TimeArray{T,1}, a::Array{Int})
    TimeArray(ta.timestamp[a], ta.values[a], ta.colnames)
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
#  counter = int(zeros(length(dates)))
  for i in 1:length(dates)
    if findfirst(ta.timestamp, dates[i]) != 0
      #counter[i] = findfirst(ta.timestamp, dates[i])
      push!(counter, findfirst(ta.timestamp, dates[i]))
    end
  end
  ta[counter]
end

function Base.getindex{T,N}(ta::TimeArray{T,N}, r::DateRange{ISOCalendar}) 
    ta[[r]]
end

# day of week
# Base.getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]
