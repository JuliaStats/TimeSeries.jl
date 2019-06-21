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

merge(x::TimeArray{T}, y::TimeArray{T}, z::TimeArray{T}, a::TimeArray{T}...; kw...) where {T} =
    merge(merge(x, y; kw...), z, a...; kw...)


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

function collapse(ta::TimeArray{T,N,D}, period::Function, timestamp::Function,
                  value::Function = timestamp) where {T,N,D}

    length(ta) == 0 && return ta

    ncols = length(colnames(ta))
    collapsed_tstamps = D[]
    collapsed_values = values(ta)[1:0, :]

    tstamp = _timestamp(ta)[1]
    mapped_tstamp = period(tstamp)
    cluster_startrow = 1

    for i in 1:length(ta)-1

        next_tstamp = _timestamp(ta)[i+1]
        next_mapped_tstamp = period(next_tstamp)

        if mapped_tstamp != next_mapped_tstamp
          push!(collapsed_tstamps, timestamp(_timestamp(ta)[cluster_startrow:i]))
          collapsed_values = [collapsed_values; T[value(values(ta)[cluster_startrow:i, j]) for j in 1:ncols] |> permutedims]
          cluster_startrow = i+1
        end #if

        tstamp = next_tstamp
        mapped_tstamp = next_mapped_tstamp

    end #for

    push!(collapsed_tstamps, timestamp(_timestamp(ta)[cluster_startrow:end]))
    collapsed_values = [collapsed_values; T[value(values(ta)[cluster_startrow:end, j]) for j in 1:ncols] |> permutedims]

    N == 1 && (collapsed_values = vec(collapsed_values))
    return TimeArray(collapsed_tstamps, collapsed_values, colnames(ta), meta(ta))

end

# vcat ######################

function vcat(TA::TimeArray...)
    # Check all meta fields are identical.
    prev_meta = meta(TA[1])
    for ta in TA
        if meta(ta) != prev_meta
            throw(ArgumentError("metadata doesn't match"))
        end
    end

    # Check column names are identical.
    prev_colnames = colnames(TA[1])
    for ta in TA
        if colnames(ta) != prev_colnames
            throw(ArgumentError("column names don't match"))
        end
    end

    # Concatenate the contents.
    ts  = vcat([timestamp(ta) for ta in TA]...)
    val = vcat([values(ta) for ta in TA]...)

    order = sortperm(ts)
    if ndims(TA[1]) == 1 # Check for 1D to ensure values remains a 1D vector.
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
