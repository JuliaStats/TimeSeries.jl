import Base: values, find

# when ############################

when(ta::TimeArray, period::Function, t::Int) =
    ta[find(period.(ta.timestamp) .== t)]
when(ta::TimeArray, period::Function, t::String) =
    ta[find(period.(ta.timestamp) .== t)]

# from, to ######################

from(ta::TimeArray{T, N, D}, d::D) where {T, N, D} =
    length(ta) == 0 ? ta :
        d < ta.timestamp[1] ? ta :
        d > ta.timestamp[end] ? ta[1:0] :
        ta[searchsortedfirst(ta.timestamp, d):end]

to(ta::TimeArray{T, N, D}, d::D) where {T, N, D} =
    length(ta) == 0 ? ta :
        d < ta.timestamp[1] ? ta[1:0] :
        d > ta.timestamp[end] ? ta :
        ta[1:searchsortedlast(ta.timestamp, d)]

###### find ##################

find(ta::TimeArray{Bool, 1}) = find(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool, 1}) = ta.timestamp[find(ta.values)]

###### head, tail ###########

function head(ta::TimeArray, n::Int=1)
    ncol          = length(ta.colnames)
    new_timestamp = ta.timestamp[1:n]
    new_values    = ta.values[1:n, 1:ncol]
    TimeArray(new_timestamp, new_values, ta.colnames, ta.meta)
end

function tail(ta::TimeArray, n::Int=1)
    ncol          = length(ta.colnames)
    tail_start = length(ta)-n+1
    new_timestamp = ta.timestamp[tail_start:end]
    new_values    = ta.values[tail_start:end, 1:ncol]
    TimeArray(new_timestamp, new_values, ta.colnames, ta.meta)
end

###### element wrapers ###########

timestamp(ta::TimeArray) = ta.timestamp
values(ta::TimeArray)    = ta.values
colnames(ta::TimeArray)  = ta.colnames
meta(ta::TimeArray)      = ta.meta
