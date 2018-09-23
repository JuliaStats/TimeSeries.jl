import Base: values

# when ############################

when(ta::TimeArray, period::Function, t::Integer) =
    ta[findall(period.(ta.timestamp) .== t)]
when(ta::TimeArray, period::Function, t::String) =
    ta[findall(period.(ta.timestamp) .== t)]

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

###### findall ##################

Base.findall(ta::TimeArray{Bool,1}) = findall(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[findall(ta.values)]

###### head, tail ###########

@generated function head(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(ta.values[1:n]) : :(ta.values[1:n, :])
    
    quote
        new_timestamp = ta.timestamp[1:n]
        TimeArray(new_timestamp, $new_values, ta.colnames, ta.meta)
    end
end

 @generated function tail(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(ta.values[start:end]) : :(ta.values[start:end, :])
    
    quote
        start = length(ta) - n + 1
        new_timestamp = ta.timestamp[start:end]
        TimeArray(new_timestamp, $new_values, ta.colnames, ta.meta)
    end
end

###### first, last ###########

Base.first(ta::TimeArray) = head(ta, 1)

Base.last(ta::TimeArray) = tail(ta, 1)

###### element wrapers ###########

timestamp(ta::TimeArray) = ta.timestamp
values(ta::TimeArray)    = ta.values
colnames(ta::TimeArray)  = ta.colnames
meta(ta::TimeArray)      = ta.meta
