import Base: merge, hcat, vcat, map

###### merge ####################

function _merge_outer(::Type{IndexType}, ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, padvalue, meta) where {IndexType,T,N,M,D}
    timestamps, new_idx1, new_idx2 = sorted_unique_merge(IndexType, timestamp(ta1), timestamp(ta2))
    vals = fill(convert(T, padvalue), (length(timestamps), length(colnames(ta1)) + length(colnames(ta2))))
    insertbyidx!(vals, values(ta1), new_idx1)
    insertbyidx!(vals, values(ta2), new_idx2, size(values(ta1), 2))
    TimeArray(timestamps, vals, [colnames(ta1); colnames(ta2)], meta; unchecked = true)
end

"""
    merge(ta1::TimeArray{T}, ta2::TimeArray{T}, [tas::TimeArray{T}...];
          method = :inner, colnames = [...], padvalue = NaN)

Merge several `TimeArray`s along with the time index.

## Argument

- `method::Symbol`: `:inner`, `:outer`, `:left` or `:right`.
"""
function merge(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D};
               method::Symbol = :inner, colnames::Vector = Symbol[], meta = nothing,
               padvalue=NaN) where {T,N,M,D}

    if colnames isa Vector{<:AbstractString}
        @warn "`merge(...; colname::Vector{<:AbstractString})` is deprecated, " *
              "use `merge(...; colnames=Symbol.(colnames))` instead."
        colnames = Symbol.(colnames)
    end

    meta = if _meta(ta1) == _meta(ta2) && meta ≡ nothing
        _meta(ta1)
    elseif typeof(_meta(ta1)) <: AbstractString && typeof(_meta(ta2)) <: AbstractString && meta ≡ nothing
        string(_meta(ta1), "_", _meta(ta2))
    else
        meta
    end

    if method == :inner

        idx1, idx2 = overlap(timestamp(ta1), timestamp(ta2))
        vals = [values(ta1[idx1]) values(ta2[idx2])]
        ta = TimeArray(timestamp(ta1[idx1]), vals, [_colnames(ta1); _colnames(ta2)], meta; unchecked = true)

    elseif method == :left

        new_idx2, old_idx2 = overlap(timestamp(ta1), timestamp(ta2))
        right_vals = fill(convert(T, padvalue), (length(ta1), length(_colnames(ta2))))
        insertbyidx!(right_vals, values(ta2), new_idx2, old_idx2)
        ta = TimeArray(timestamp(ta1), [values(ta1) right_vals], [_colnames(ta1); _colnames(ta2)], meta; unchecked = true)

    elseif method == :right

        ta = merge(ta2, ta1, method = :left; padvalue = padvalue)
        ncol2 = length(_colnames(ta2))
        vals = [values(ta)[:, (ncol2+1):end] values(ta)[:, 1:ncol2]]
        ta = TimeArray(timestamp(ta), vals, [_colnames(ta1); _colnames(ta2)], meta; unchecked = true)

    elseif method == :outer

        ta = if (length(timestamp(ta1)) + length(timestamp(ta2))) > typemax(Int32)
            _merge_outer(Int64, ta1, ta2, padvalue, meta)
        else
            _merge_outer(Int32, ta1, ta2, padvalue, meta)
        end

    else
        throw(ArgumentError(
            "merge method must be one of :inner, :left, :right, :outer"))
    end

    return rename!(ta, colnames)

end

merge(x::TimeArray{T}, y::TimeArray{T}, z::TimeArray{T}, a::TimeArray{T}...;
      colnames::Vector = Symbol[], kw...) where {T} =
    rename!(merge(merge(x, y; kw...), z, a...; kw...), colnames)


# hcat ##########################

function hcat(x::TimeArray, y::TimeArray)
    tsx = timestamp(x)
    tsy = timestamp(y)

    if length(tsx) != length(tsx) || tsx != tsy
        throw(DimensionMismatch(
            "timestamps not consistent, please checkout `merge`."))
    end

    m = ifelse(meta(x) == meta(y), meta(x), nothing)

    TimeArray(tsx, [values(x) values(y)], [colnames(x); colnames(y)], m)
end

hcat(x::TimeArray, y::TimeArray, zs::Vararg{TimeArray}) =
    hcat(hcat(x, y), zs...)

# collapse ######################

# accessors functions
# https://github.com/JuliaLang/julia/blob/b617e8d3a77e49cd5625ca663af88e40f7796f15/stdlib/Dates/src/accessors.jl#L50

# `year` doesn't need this wrapper
for (F, T, P) ∈ ((:quarter,     :TimeType,               :Quarter),
                 (:month,       :TimeType,               :Month),
                 (:week,        :TimeType,               :Week),
                 (:day,         :TimeType,               :Day),
                 (:hour,        :(Union{DateTime,Time}), :Hour),
                 (:minute,      :(Union{DateTime,Time}), :Minute),
                 (:second,      :(Union{DateTime,Time}), :Second),
                 (:millisecond, :(Union{DateTime,Time}), :Millisecond),
                 (:microsecond, :Time,                   :Microsecond),
                 (:nanosecond,  :Time,                   :Nanosecond))
    if F === :quarter
        (VERSION < v"1.6") && continue
        F = :(Dates.quarter)
    end
    @eval let
        global collapse
        wrapper(x::$T) = floor(x, $P(1))
        collapse(ta::TimeArray, ::typeof($F), f::Function, g::Function = f; kw...) =
            collapse(ta, wrapper, f, g; kw...)
    end
end

function collapse(ta::TimeArray, period::Function, timestamp::Function,
                  value::Function = timestamp)

    isempty(ta) && return ta

    m, n = length(ta), length(colnames(ta))
    ts   = _timestamp(ta)
    val  = _values(ta)
    idx  = UnitRange{Int}[]
    sizehint!(idx, m)

    t₀ = period(ts[1])
    j  = 1
    for i in 1:m-1
        t₁ = period(ts[i+1])
        t₀ == t₁ && continue
        push!(idx, j:i)
        j = i + 1
        t₀ = t₁
    end
    push!(idx, j:m)

    ts′  = [timestamp(@view(ts[i])) for i ∈ idx]
    val′ = if n == 1
        [value(@view(val[i])) for i ∈ idx]
    else
        [value(@view(val[i, k])) for i ∈ idx, k ∈ 1:n]
    end

    TimeArray(ts′, val′, colnames(ta), meta(ta))
end

"""
    $(SIGNATURES)

The `collapse` method allows for compressing data into a larger time frame. 

For example, converting daily data into monthly data. When compressing dates, something rational has to be done with the values
that lived in the more granular time frame. To define what happens, a function call is made.

## Arguments:
- `ta::TimeArray`: Original data
- `period::Union{Function,Dates.Period}`: Period or method for determining the period
- `timestamp::Function`: Method that determines which timestamp represents the whole period, e.g. `last`
- `value::Function = timestamp`: Method that should be applied to the data within the period, e.g. `mean`

```julia
collapse(ta, month, last)
collapse(ta, month, last, mean)
```
"""
collapse(ta::TimeArray, period::Period, timestamp::Function, value::Function = timestamp; kw...) =
    collapse(ta, x -> floor(x, period), timestamp, value; kw...)

# vcat ######################

"""
    $(SIGNATURES)

Concatenate two ``TimeArray`` into single object.

If there are duplicated timestamps, we will keep order as the function input.

```julia-repl
julia> a = TimeArray([Date(2015, 10, 1), Date(2015, 10, 2), Date(2015, 10, 3)], [1, 2, 3]);

julia> b = TimeArray([Date(2015, 10, 2), Date(2015, 10, 3)], [4, 5]);

julia> [a; b]
5×1 TimeArray{Int64,1,Date,Array{Int64,1}} 2015-10-01 to 2015-10-03
│            │ A     │
├────────────┼───────┤
│ 2015-10-01 │ 1     │
│ 2015-10-02 │ 2     │
│ 2015-10-02 │ 4     │
│ 2015-10-03 │ 3     │
│ 2015-10-03 │ 5     │
```
"""
function vcat(tas::TimeArray...)
    # Check all meta fields are identical.
    prev_meta = meta(tas[1])
    for ta in tas
        if meta(ta) != prev_meta
            throw(ArgumentError("metadata doesn't match"))
        end
    end

    # Check column names are identical.
    prev_colnames = colnames(tas[1])
    for ta in tas
        if colnames(ta) != prev_colnames
            throw(ArgumentError("column names don't match"))
        end
    end

    # Concatenate the contents.
    ts  = vcat([timestamp(ta) for ta in tas]...)
    val = vcat([values(ta) for ta in tas]...)

    order = sortperm(ts)
    if ndims(tas[1]) == 1 # Check for 1D to ensure values remains a 1D vector.
        return TimeArray(ts[order], val[order], prev_colnames, prev_meta)
    else
        return TimeArray(ts[order], val[order, :], prev_colnames, prev_meta)
    end
end

# map ######################

@generated function map(f, ta::TimeArray{T,N}) where {T,N}
    input_val  = (N == 1) ? :(values(ta)[i]) : :(vec(values(ta)[i, :]))
    output_val = (N == 1) ? :(vals[i]) : :(vals[i, :])

    output_vals = (N == 1) ? :(vals[order]) : :(vals[order, :])

    quote
        ts   = similar(timestamp(ta))
        vals = similar(values(ta))

        for i in eachindex(ta)
            @inbounds ts[i], $output_val = f(timestamp(ta)[i], $input_val)
        end

        order = sortperm(ts)
        TimeArray(ts[order], $output_vals, colnames(ta), meta(ta))
    end
end
