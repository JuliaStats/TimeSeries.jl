import Base: values, find

# when ############################

when{T,N}(ta::TimeArray{T,N}, period::Function, t::Int)         = ta[find(period(ta.timestamp) .== t)]
when{T,N}(ta::TimeArray{T,N}, period::Function, t::ASCIIString) = ta[find(period(ta.timestamp) .== t)]

# from, to ######################
 
from{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    d < ta.timestamp[1] ? ta :
    d > ta.timestamp[end] ? ta[1:0] :
    ta[searchsortedfirst(ta.timestamp, d):end]

to{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    d < ta.timestamp[1] ? ta[1:0] :
    d > ta.timestamp[end] ? ta :
    ta[1:searchsortedlast(ta.timestamp, d)]

###### find ##################

find(ta::TimeArray{Bool,1}) = find(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[find(ta.values)]

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
