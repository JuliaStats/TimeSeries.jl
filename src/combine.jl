import Base: merge, hcat, vcat, map

###### merge ####################

function _merge_outer(::Type{IndexType}, ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, padvalue, meta) where {IndexType,T,N,M,D}
    timestamps, new_idx1, new_idx2 = sorted_unique_merge(IndexType, ta1.timestamp, ta2.timestamp)
    vals = fill(convert(T, padvalue), (length(timestamps), length(ta1.colnames) + length(ta2.colnames)))
    insertbyidx!(vals, ta1.values, new_idx1)
    insertbyidx!(vals, ta2.values, new_idx2, size(ta1.values, 2))
    TimeArray(timestamps, vals, [ta1.colnames; ta2.colnames], meta; unchecked = true)
end

function merge(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, method::Symbol = :inner;
               colnames::Vector = [], meta = nothing,
               padvalue=NaN) where {T,N,M,D}

    if colnames isa Vector{<:AbstractString}
        @warn "`merge(...; colname::Vector{<:AbstractString})` is deprecated, " *
              "use `merge(...; colnames=Symbol.(colnames))` instead."
        colnames = Symbol.(colnames)
    end

    if ta1.meta == ta2.meta && meta isa Nothing
        meta = ta1.meta
    elseif typeof(ta1.meta) <: AbstractString && typeof(ta2.meta) <: AbstractString && meta isa Nothing
        meta = string(ta1.meta, "_", ta2.meta)
    else
        meta = meta
    end

    if method == :inner

        idx1, idx2 = overlap(ta1.timestamp, ta2.timestamp)
        vals = [ta1[idx1].values ta2[idx2].values]
        ta = TimeArray(ta1[idx1].timestamp, vals, [ta1.colnames; ta2.colnames], meta; unchecked = true)

    elseif method == :left

        new_idx2, old_idx2 = overlap(ta1.timestamp, ta2.timestamp)
        right_vals = fill(convert(T, padvalue), (length(ta1), length(ta2.colnames)))
        insertbyidx!(right_vals, ta2.values, new_idx2, old_idx2)
        ta = TimeArray(ta1.timestamp, [ta1.values right_vals], [ta1.colnames; ta2.colnames], meta; unchecked = true)

    elseif method == :right

        ta = merge(ta2, ta1, :left; padvalue = padvalue)
        ncol2 = length(ta2.colnames)
        vals = [values(ta)[:, (ncol2+1):end] values(ta)[:, 1:ncol2]]
        ta = TimeArray(timestamp(ta), vals, [ta1.colnames; ta2.colnames], meta; unchecked = true)

    elseif method == :outer

        ta = if (length(ta1.timestamp) + length(ta2.timestamp)) > typemax(Int32)
            _merge_outer(Int64, ta1, ta2, padvalue, meta)
        else
            _merge_outer(Int32, ta1, ta2, padvalue, meta)
        end

    else
        throw(ArgumentError(
            "merge method must be one of :inner, :left, :right, :outer"))
    end

    return setcolnames!(ta, colnames)

end

# hcat ##########################

function hcat(x::TimeArray, y::TimeArray)
    tsx = x.timestamp
    tsy = y.timestamp

    if length(tsx) != length(tsx) || tsx != tsy
        throw(DimensionMismatch(
            "timestamps not consistent, please checkout `merge`."))
    end

    meta = ifelse(x.meta == y.meta, x.meta, nothing)

    TimeArray(tsx, [x.values y.values], [x.colnames; y.colnames], meta)
end

hcat(x::TimeArray, y::TimeArray, zs::Vararg{TimeArray}) =
    hcat(hcat(x, y), zs...)

# collapse ######################

function collapse(ta::TimeArray{T, N, D}, period::Function, timestamp::Function,
                  value::Function=timestamp) where {T, N, D}

    length(ta) == 0 && return ta

    ncols = length(colnames(ta))
    collapsed_tstamps = D[]
    collapsed_values = values(ta)[1:0, :]

    tstamp = timestamp(ta)[1]
    mapped_tstamp = period(tstamp)
    cluster_startrow = 1

    for i in 1:length(ta)-1

        next_tstamp = timestamp(ta)[i+1]
        next_mapped_tstamp = period(next_tstamp)

        if mapped_tstamp != next_mapped_tstamp
          push!(collapsed_tstamps, timestamp(timestamp(ta)[cluster_startrow:i]))
          collapsed_values = [collapsed_values; T[value(values(ta)[cluster_startrow:i, j]) for j in 1:ncols]']
          cluster_startrow = i+1
        end #if

        tstamp = next_tstamp
        mapped_tstamp = next_mapped_tstamp

    end #for

    push!(collapsed_tstamps, timestamp(timestamp(ta)[cluster_startrow:end]))
    collapsed_values = [collapsed_values; T[value(values(ta)[cluster_startrow:end, j]) for j in 1:ncols]']

    N == 1 && (collapsed_values = vec(collapsed_values))
    return TimeArray(collapsed_tstamps, collapsed_values, colnames(ta), ta.meta)

end

# vcat ######################

function vcat(TA::TimeArray...)
    # Check all meta fields are identical.
    prev_meta = TA[1].meta
    for ta in TA
        if ta.meta != prev_meta
            throw(ArgumentError("metadata doesn't match"))
        end
    end

    # Check column names are identical.
    prev_colnames = TA[1].colnames
    for ta in TA
        if colnames(ta) != prev_colnames
            throw(ArgumentError("column names don't match"))
        end
    end

    # Concatenate the contents.
    timestamps = vcat([timestamp(ta) for ta in TA]...)
    values = vcat([values(ta) for ta in TA]...)

    order = sortperm(timestamps)
    if length(TA[1].colnames) == 1 # Check for 1D to ensure values remains a 1D vector.
        return TimeArray(timestamps[order], values[order], TA[1].colnames, TA[1].meta)
    else
        return TimeArray(timestamps[order], values[order, :], TA[1].colnames, TA[1].meta)
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
        TimeArray(ts[order], $output_vals, colnames(ta), ta.meta)
    end
end
