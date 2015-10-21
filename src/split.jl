import Base.values

# by ############################

function by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) 
    boolarray = [[period(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t;] # odd syntax for t; but just t deprecated
    rownums = round(Int64, zeros(sum(boolarray)))
    j = 1
    for i in 1:length(boolarray)
        if boolarray[i]
            rownums[j] = i
            j+=1
        end
    end
    ta[rownums]
end 
 
# from, to ######################
 
from{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    d < ta.timestamp[1] ? ta :
    d > ta.timestamp[end] ? ta[1:0] :
    ta[searchsortedfirst(ta.timestamp, d):end]

to{T,N,D}(ta::TimeArray{T,N,D}, d::D) =
    d < ta.timestamp[1] ? ta[1:0] :
    d > ta.timestamp[end] ? ta :
    ta[1:searchsortedlast(ta.timestamp, d)]

###### findall ##################

findall(ta::TimeArray{Bool,1}) = find(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[find(ta.values)]

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
