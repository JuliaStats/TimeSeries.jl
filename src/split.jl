import Base: values, find

# when ############################

when{T,N}(ta::TimeArray{T,N}, period::Function, t::Int)         = ta[find(period(ta.timestamp) .== t)]
when{T,N}(ta::TimeArray{T,N}, period::Function, t::ASCIIString) = ta[find(period(ta.timestamp) .== t)]

# from, to ######################
 
from{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    length(ta) == 0 ? ta : 
         d < ta.timestamp[1] ? ta :
         d > ta.timestamp[end] ? ta[1:0] :
         ta[searchsortedfirst(ta.timestamp, d):end]

to{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    length(ta) == 0 ? ta : 
        d < ta.timestamp[1] ? ta[1:0] :
        d > ta.timestamp[end] ? ta :
        ta[1:searchsortedlast(ta.timestamp, d)]

###### find ##################

find(ta::TimeArray{Bool,1}) = find(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[find(ta.values)]

###### head, tail ###########

function head{T,N,D}(ta::TimeArray{T,N,D}, n::Int=1)
    new_timestamp = ta.timestamp[1:n]
    new_values    = ta.values[1:n]
    TimeArray(new_timestamp, new_values, ta.colnames, ta.meta)
end

function tail{T,N,D}(ta::TimeArray{T,N,D}, n::Int=1)
    tail_start = length(ta)-n+1
    new_timestamp = ta.timestamp[tail_start:end]
    new_values    = ta.values[tail_start:end]
    TimeArray(new_timestamp, new_values, ta.colnames, ta.meta)
end

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
