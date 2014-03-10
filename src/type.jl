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

#################################
###### length ###################
#################################

function Base.length(ta::TimeArray)
    length(ta.timestamp)
end

###### show #####################
 
function Base.show(io::IO, ta::TimeArray)
  # variables 
  nrow          = size(ta.values, 1)
  ncol          = size(ta.values, 2)
  spacetime     = strwidth(string(ta.timestamp[1])) + 3
  firstcolwidth = strwidth(ta.colnames[1])
  colwidth      = Int[]
      for m in 1:ncol
          push!(colwidth, max(strwidth(ta.colnames[m]), strwidth(@sprintf("%.3f", maximum(ta.values[:,m])))))
      end

  # summary line
  print(@sprintf("%dx%d %s %s to %s", nrow, ncol, typeof(ta), string(ta.timestamp[1]), string(ta.timestamp[nrow])))
  println("")
  println("")

  # row label line

  #firstcolwidth > maxcolwidth(ta.values[:,1]) ?

  # print(io, ^(" ", spacetime-1), ta.colnames[1], ^(" ", maxcolwidth(ta.values[:,1]) + 2 -firstcolwidth)) :
  # print(io, ^(" ", spacetime), ta.colnames[1], ^(" ", maxcolwidth(ta.values[:,1]) + 2 -firstcolwidth))
   print(io, ^(" ", spacetime), ta.colnames[1], ^(" ", colwidth[1] + 2 -firstcolwidth))

  for p in 2:length(colwidth)
  #for p in 2:length(ta.colnames)
    #nextcolwidth = strwidth(ta.colnames[p])
##     nextcolwidth = colwidth[p]
##     if nextcolwidth > 8  
##         stophere = 8
##     else  
##         stophere = nextcolwidth
##     end
 #   print(io, ta.colnames[p], ^(" ", maxcolwidth(ta.values[:,p]) + 2 - nextcolwidth))
    #print(io, ta.colnames[p][1:stophere], ^(" ", maxcolwidth(ta.values[:,p]) + 2 - nextcolwidth))
#    print(io, ta.colnames[p][1:stophere], ^(" ", maxcolwidth(ta.values[:,p]) + 2 - min(nextcolwidth,8)))
     print(io, ta.colnames[p], ^(" ", colwidth[p] - strwidth(ta.colnames[p]) + 2))
   end
   println("")
# 
  # timestamp and values line
#   if nrow > 7
#     for i in 1:4
#       isa(ta.values[1], Float64)?
#       println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], "  ")):
#       println(io, ta.timestamp[i], " | ", join([@sprintf("%s", t) for t in ta.values[i,:]], "  "))
#     end
#     println("...")
#     for j in nrow-4:nrow
#       isa(ta.values[1], Float64)?
#       println(io, ta.timestamp[j], " | ", join([@sprintf("%.3f", t) for t in ta.values[j,:]], "  ")):
#       println(io, ta.timestamp[j], " | ", join([@sprintf("%s", t) for t in ta.values[j,:]], "  "))
#     end
#   else
#     for k in 1:nrow
#       isa(ta.values[1], Float64)?
#       println(io, ta.timestamp[k], " | ", join([@sprintf("%.3f", t) for t in ta.values[k,:]], "  ")):
#       println(io, ta.timestamp[k], " | ", join([@sprintf("%s", t) for t in ta.values[k,:]], "  "))
#     end
#   end

for i in 1:nrow
    #println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], "  "))
    println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], "    "))
    #println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], [^(" ", c) for c in colwidth]))
    #println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], ^(" ", 2) ))
    #println(io, ta.timestamp[i], " | ", join([@sprintf("%.3f", t) for t in ta.values[i,:]], ^(" ", maximum(2, colwidth[3]-5)) ))
end


###      for i in 1:nrow
###          for j in 1:ncol
###              valprint = @sprintf "%.3f" ta.values[i,j]
###              println(io, ta.timestamp[i], " | ", join(valprint, ^(" ", colwidth[i] - strwidth(valprint))))
###          end
###     end


end

## function maxcolwidth(x)
##     isa(x[1], Float64)?
##     strwidth(@sprintf("%.3f", maximum(x))):
##     isa(x[1], Bool)?
##     strwidth(@sprintf("%s", minimum(x))):
##     8
## end

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
