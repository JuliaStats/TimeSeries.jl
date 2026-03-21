# when ############################

"""
    when(ta::TimeArray, period::Function, t::Integer)

Return a subset of `TimeArray` where the period function applied to timestamps equals `t`.
"""
function when(ta::TimeArray, period::Function, t::Integer)
    return ta[findall(period.(timestamp(ta)) .== t)]
end
when(ta::TimeArray, period::Function, t::String) = ta[findall(period.(timestamp(ta)) .== t)]

struct TimeWindow
    from::Time
    to::Time
end

time_slots(; from::Time, to::Time) = TimeWindow(from, to)

"""
    when(ta::TimeArray, window::TimeWindow)

Return a subset of `TimeArray` where the time of each timestamp falls
within the daily window `[window.from, window.to]`.
"""
function when(ta::TimeArray, window::TimeWindow)
    return ta[findall(t -> window.from <= Time(t) <= window.to, timestamp(ta))]
end

struct TimeSlot{T<:TimeType,P<:Period}
    start::T
    stop::T
    interval::P
    from::Time
    to::Time
end

Base.IteratorSize(::Type{<:TimeSlot}) = Base.SizeUnknown()
Base.eltype(::Type{TimeSlot{T,P}}) where {T,P} = T

function Base.iterate(ts::TimeSlot{T}) where {T}
    current = ts.start
    while current <= ts.stop
        if ts.from <= Time(current) <= ts.to
            return (current, current + ts.interval)
        end
        current += ts.interval
    end
    return nothing
end

function Base.iterate(ts::TimeSlot{T}, state::T) where {T}
    current = state
    while current <= ts.stop
        if ts.from <= Time(current) <= ts.to
            return (current, current + ts.interval)
        end
        current += ts.interval
    end
    return nothing
end

"""
    time_slots(start::T, stop::T, interval::Period;
                    from::Time=Time(0,0), to::Time=Time(23,59))

Return A `TimeSlot` iterator where each timestamp falls within the daily time 
window `[from, to]`,
filtered from the full `start` to `stop` range at the given `interval`
"""
function time_slots(
    start::T, stop::T, interval::P; from::Time=Time(0, 0), to::Time=Time(23, 59)
) where {T<:TimeType,P<:Period}
    # TODO: Negative intervals are currently unsupported and raise an ArgumentError.
    # Supporting them is non-trivial due to edge cases where the step crosses a
    # day boundary in reverse, e.g.:
    #   DateTime(2023, 1, 2, 0, 3):Minute(-4):DateTime(2023, 1, 1)
    # In this case it's unclear how the from/to time window should be applied.
    # Check for negative or zero period
    if interval <= zero(interval)
        throw(ArgumentError("interval must be positive, got $interval"))
    end

    return TimeSlot{T,P}(start, stop, interval, from, to)
end

"""
   time_slots(range::StepRange{T};
                    from::Time=Time(0,0), to::Time=Time(23,59))
                    
Return A `TimeSlot` iterator where each timestamp falls within the daily time 
window `[from, to]`,
filtered from the given `range`
"""
function time_slots(
    range::StepRange{T,P}; from::Time=Time(0, 0), to::Time=Time(23, 59)
) where {T<:TimeType,P<:Period}
    # TODO: Negative intervals are currently unsupported and raise an ArgumentError.
    # Supporting them is non-trivial due to edge cases where the step crosses a
    # day boundary in reverse, e.g.:
    #   DateTime(2023, 1, 2, 0, 3):Minute(-4):DateTime(2023, 1, 1)
    # In this case it's unclear how the from/to time window should be applied.
    if step(range) <= zero(step(range))
        throw(ArgumentError("interval must be positive, got $(step(range))"))
    end
    return TimeSlot{T,P}(range.start, range.stop, step(range), from, to)
end
# from, to ######################

"""
    from(ta::TimeArray{T,N,D}, d::D)

Return the part of `TimeArray` from the first timestamp >= `d`.
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
    to(ta::TimeArray{T,N,D}, d::D)

Return the part of `TimeArray` up to the last timestamp <= `d`.
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

Return timestamps where the values of a boolean `TimeArray` are true.
"""
findwhen(ta::TimeArray{Bool,1}) = timestamp(ta)[findall(values(ta))]

###### head, tail ###########

"""
    head(ta::TimeArray{T,N}, n::Int=6)

Return the first `n` rows of a `TimeArray`.
"""
@generated function head(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[1:n]) : :(values(ta)[1:n, :])

    quote
        new_timestamp = timestamp(ta)[1:n]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

"""
    tail(ta::TimeArray{T,N}, n::Int=6)

Return the last `n` rows of a `TimeArray`.
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
