type TimeArray{T,N}
  timestamp::Array{Date{ISOCalendar},1}
  values::Array{T,N}
  colnames::Array(String,1}
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
getindex(ta::TimeArray, n::Int64)
  [ta.timestamp[n] ta.values[n]] 
end


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
