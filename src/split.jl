# when ############################

"""
    when(ta::TimeArray, period::Function, t)

Filter a `TimeArray` to rows where the `period` function applied to timestamps equals `t`.

# Arguments

  - `ta::TimeArray`: The time array to filter
  - `period::Function`: A function that extracts a period component (e.g., `Dates.hour`, `Dates.dayofweek`)
  - `t`: The target value to match (Integer or String)

# Examples

```julia
when(ta, Dates.hour, 12)  # Get all rows at noon
when(ta, Dates.dayofweek, 1)  # Get all Monday rows
```
"""
function when(ta::TimeArray, period::Function, t::Integer)
    return ta[findall(period.(timestamp(ta)) .== t)]
end
when(ta::TimeArray, period::Function, t::String) = ta[findall(period.(timestamp(ta)) .== t)]

# from, to ######################

"""
    from(ta::TimeArray, d::TimeType)

Select all rows from a `TimeArray` starting from date `d` onwards.

# Examples

```julia
from(ta, Date(2020, 1, 1))  # All rows from 2020-01-01 onwards
```
"""
function from(ta::TimeArray{T,N,D}, d::D) where {T,N,D}
    return if length(ta) == 0
        ta
    elseif d < timestamp(ta)[1]
        ta
    elseif d > timestamp(ta)[end]
        ta[1:0]
    else
        ta[searchsortedfirst(timestamp(ta), d):end]
    end
end

"""
    to(ta::TimeArray, d::TimeType)

Select all rows from a `TimeArray` up to and including date `d`.

# Examples

```julia
to(ta, Date(2020, 12, 31))  # All rows up to 2020-12-31
```
"""
function to(ta::TimeArray{T,N,D}, d::D) where {T,N,D}
    return if length(ta) == 0
        ta
    elseif d < timestamp(ta)[1]
        ta[1:0]
    elseif d > timestamp(ta)[end]
        ta
    else
        ta[1:searchsortedlast(timestamp(ta), d)]
    end
end

###### findall ##################

Base.findall(ta::TimeArray{Bool,1}) = findall(values(ta))
Base.findall(f::Function, ta::TimeArray{T,1}) where {T} = findall(f, values(ta))
function Base.findall(f::Function, ta::TimeArray{T,2}) where {T}
    A = values(ta)
    return collect(i for i in axes(A, 1) if f(view(A, i, :)))
end

###### findwhen #################

"""
    findwhen(ta::TimeArray{Bool,1})

Return timestamps where the boolean `TimeArray` has `true` values.

# Examples

```julia
findwhen(ta .> 100)  # Get timestamps where values exceed 100
```
"""
findwhen(ta::TimeArray{Bool,1}) = timestamp(ta)[findall(values(ta))]

###### head, tail ###########

"""
    head(ta::TimeArray, n::Int=6)

Return the first `n` rows of a `TimeArray`.

# Examples

```julia
head(ta)     # First 6 rows
head(ta, 10) # First 10 rows
```
"""
@generated function head(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[1:n]) : :(values(ta)[1:n, :])

    quote
        new_timestamp = timestamp(ta)[1:n]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

"""
    tail(ta::TimeArray, n::Int=6)

Return the last `n` rows of a `TimeArray`.

# Examples

```julia
tail(ta)     # Last 6 rows
tail(ta, 10) # Last 10 rows
```
"""
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
function Base.split(data::TimeSeries.TimeArray, period::Function)
    Iterators.map(i -> data[i], _split(TimeSeries.timestamp(data), period))
end

function _split(ts::AbstractVector{D}, period::Function) where {D<:TimeType}
    m = length(ts)
    idx = UnitRange{Int}[]
    isempty(ts) && return idx

    sizehint!(idx, m)
    t0 = period(ts[1])
    j = 1
    for i in 1:(m - 1)
        t1 = period(ts[i + 1])
        t0 == t1 && continue
        push!(idx, j:i)
        j = i + 1
        t0 = t1
    end
    push!(idx, j:m)

    return Iterators.map(i -> ts[i], idx)
end
