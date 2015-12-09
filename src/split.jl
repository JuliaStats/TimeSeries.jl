import Base.values

# when ############################

when{T,N}(ta::TimeArray{T,N}, period::Function, t::Int)         = ta[find(period(ta.timestamp) .== t)]
when{T,N}(ta::TimeArray{T,N}, period::Function, t::ASCIIString) = ta[find(period(ta.timestamp) .== t)]

# from, to ######################
 
from{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int) = ta[Date(y,m,d):last(ta.timestamp)]
to{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)   = ta[ta.timestamp[1]:Date(y,m,d)]

###### findall ##################

import Base.find

findall(ta::TimeArray{Bool,1}) = find(ta.values)
find(ta::TimeArray{Bool,1})    = ta[(findall(ta))]

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[find(ta.values)]

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
