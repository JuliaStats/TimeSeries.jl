type TimeArray{T,N}
  timestamp::Array{Date{ISOCalendar},1}
  values::Array{T,N}
  colnames::Array{String,1}
end
 
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
  nams = String[arg[1].name for arg in args]

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
  println("summary of dimensions, etc")
  for p in 1:length(ta.colnames)
    print(io, "   ", ta.colnames[p])
  end
  println("")
  for i in 1:4
    print(io, ta.timestamp[i], "  ", ta.values[i,:])
  end
  println("...")
  for j in length(ta.timestamp)-4:length(ta.timestamp)
    print(io, ta.timestamp[j], "  ", ta.values[j,:])
  end
end

#################################
###### getindex #################
#################################

#getindex{T,N}(ta::TimeArray{T,N}, n::Int64)
# getindex(ta::TimeArray, n::Int64)
#   [ta.timestamp[n] ta.values[n]] 
# end
# 

## function getindex{T <: Date{ISOCalendar}, V}(sa::Array{SeriesPair{T, V}, 1}, mydate::Date{ISOCalendar})
##   for i in 1:size(sa,1)
##     if mydate == sa[i].timestamp 
##       return sa[i] 
##     else 
##       nothing
##     end
##   end
## end
 
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
