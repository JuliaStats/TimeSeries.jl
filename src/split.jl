# when ############################

when(ta::TimeArray, period::Function, t::Integer) =
    ta[findall(period.(timestamp(ta)) .== t)]
when(ta::TimeArray, period::Function, t::String) =
    ta[findall(period.(timestamp(ta)) .== t)]

# from, to ######################

from(ta::TimeArray{T,N,D}, d::D) where {T,N,D} =
    length(ta) == 0 ? ta :
    d < timestamp(ta)[1] ? ta :
    d > timestamp(ta)[end] ? ta[1:0] :
    ta[searchsortedfirst(timestamp(ta), d):end]

to(ta::TimeArray{T,N,D}, d::D) where {T,N,D} =
    length(ta) == 0 ? ta :
    d < timestamp(ta)[1] ? ta[1:0] :
    d > timestamp(ta)[end] ? ta :
    ta[1:searchsortedlast(timestamp(ta), d)]

###### findall ##################

Base.findall(ta::TimeArray{Bool,1}) = findall(values(ta))
Base.findall(f::Function, ta::TimeArray{T,1}) where {T} = findall(f, values(ta))
function Base.findall(f::Function, ta::TimeArray{T,2}) where {T}
    A = values(ta)
    collect(i for i in axes(A, 1) if f(view(A, i, :)))
end

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = timestamp(ta)[findall(values(ta))]

###### head, tail ###########

@generated function head(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[1:n]) : :(values(ta)[1:n, :])

    quote
        new_timestamp = timestamp(ta)[1:n]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

@generated function tail(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[start:end]) : :(values(ta)[start:end, :])

    quote
        start = length(ta) - n + 1
        new_timestamp = timestamp(ta)[start:end]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

###### first, last ###########

Base.first(ta::TimeArray) = head(ta, 1)

Base.last(ta::TimeArray) = tail(ta, 1)


"""
    split(data::TimeSeries.TimeArray, period::Function)

Split `data` by `period` function, returns a vector of `TimeSeries.TimeArray`.

## Arguments

- `data::TimeSeries.TimeArray`: Data to split
- `period::Function`: Function, e.g. `Dates.day` that is used to split the `data`.
"""
Base.split(data::TimeSeries.TimeArray, period::Function) = Iterators.map(i -> data[i], _split(TimeSeries.timestamp(data), period))

function _split(ts::AbstractVector{D}, period::Function) where {D<:TimeType}
    m = length(ts)
    idx = UnitRange{Int}[]
    isempty(ts) && return idx

    sizehint!(idx, m)
    t0 = period(ts[1])
    j = 1
    for i in 1:(m-1)
        t1 = period(ts[i+1])
        t0 == t1 && continue
        push!(idx, j:i)
        j = i + 1
        t0 = t1
    end
    push!(idx, j:m)

    return idx
end