type TimeArray{T,N}
  timestamp::Array{Date{ISOCalendar},1}
  values::Array{T,N}
  colnames::Array{ASCIIString,1}
end

# from single values
function TimeArray{T,N}(d::Date{ISOCalendar}, v::Array{T,N}, c::Array{ASCIIString,1})
  TimeArray([d], v, c)
end

# combining arrays of SeriesPairs
function TimeArray{T}(args::Array{SeriesPair{Date{ISOCalendar}, T},1}...)
  
  # create array of index values from args
  allkey = Date{ISOCalendar}[]
  for arg in args
    for ar in arg
      push!(allkey, ar.index)
    end
  end

  # and sort without duplicates
  key = sortandremoveduplicates(allkey)

  # match each arg in args with key 
  arr = fill(NaN, length(key), length(args))
    for i in 1:length(args)
      for j = 1:length(args[i])
        t = args[i][j].index .== key
        k = findfirst(t)
        arr[k,i] = args[i][j].value 
      end
    end
  
  # finally get an array of the names
  nams = ASCIIString[arg[1].name for arg in args]

  TimeArray(key, arr, nams)
end

#################################
# sortandremoveduplicates #######
#################################

function sortandremoveduplicates(x::Array)
  sx = sort(x)
  res = [sx[1]]
  for i = 2:length(sx)
    if sx[i] > sx[i-1]
    push!(res, sx[i])
    end
  end
  res
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
  print(@sprintf "%dx%d %s %s to %s" nrow ncol typeof(ta.values) string(ta.timestamp[1]) string(ta.timestamp[nrow]))
  println("")
  println("")

  # row label line
  firstcolwidth = strwidth(ta.colnames[1])
  print(io, ^(" ", spacetime+3), ta.colnames[1], ^(" ", 11-firstcolwidth))
  for p in 2:length(ta.colnames)
    nextcolwidth = strwidth(ta.colnames[p])
    print(io, ta.colnames[p], ^(" ", 8-nextcolwidth))
  end
  println("")

  # timestamp and values line
  if nrow > 7
    for i in 1:4
      print(io, ta.timestamp[i], " | ", ta.values[i,:])
    end
    println("...")
    for j in nrow-4:nrow
      print(io, ta.timestamp[j], " | ", ta.values[j,:])
    end
  else
    for k in 1:nrow
      vals = split(string(ta.values[k,:]))'
      print(io, ta.timestamp[k], " | ", vals)
    end
  end
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
###### +, -, *, / ###############
#################################
 
## # operations between two SeriesPairs
## for op in [:+, :-, :*, :/, :>, :<, :>=, :<=,
##            :.+, :.-, :.*, :./, :.>, :.<, :.>=, :.<=]
## 
##   @eval begin
##     function ($op){T,V}(sp1::SeriesPair{T,V}, sp2::SeriesPair{T,V})
##       matches = false 
##       if sp1.timestamp == sp2.timestamp
##          matches = true
##          res = SeriesPair(sp1.timestamp, ($op)(sp1.value, sp2.value))
##       end
##       matches == true? res: nothing  # nothing is indignity enough rather than an error
##     end
##   end
## end
 
## # operations between SeriesPair and Int,Float64
## for op in [:+, :-, :*, :/, :.+, :.-, :.*, :./]
##   @eval begin
##     function ($op){T,V}(sp::SeriesPair{T,V}, var::Union(Int,Float64))
##       SeriesPair(sp.timestamp, ($op)(sp.value, var))
##     end
##   end
## end
