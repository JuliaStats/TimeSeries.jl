import Base: merge, vcat, map

###### merge ####################

function merge(ta1::TimeArray{T, N, D}, ta2::TimeArray{T, M, D}, method::Symbol=:inner;
               colnames::Vector=[], meta::Any=Void) where {T, N, M, D}

    if ta1.meta == ta2.meta && meta == Void
        meta = ta1.meta
    elseif typeof(ta1.meta) <: AbstractString && typeof(ta2.meta) <: AbstractString && meta == Void
        meta = string(ta1.meta, "_", ta2.meta)
    else
        meta = meta
    end

    if method == :inner

        idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
        vals = [ta1[idx1].values ta2[idx2].values]
        ta = TimeArray(ta1[idx1].timestamp, vals, [ta1.colnames; ta2.colnames], meta)

    elseif method == :left

        new_idx2, old_idx2 = overlaps(ta1.timestamp, ta2.timestamp)
        right_vals = NaN * zeros(length(ta1), length(ta2.colnames))
        right_vals[new_idx2, :]  = ta2.values[old_idx2, :]
        ta = TimeArray(ta1.timestamp, [ta1.values right_vals], [ta1.colnames; ta2.colnames], meta)

    elseif method == :right

        ta = merge(ta2, ta1, :left)
        ncol2 = length(ta2.colnames)
        vals = [ta.values[:, (ncol2+1):end] ta.values[:, 1:ncol2]]
        ta = TimeArray(ta.timestamp, vals, [ta1.colnames; ta2.colnames], meta)

    elseif method == :outer

        timestamps = sorted_unique_merge(ta1.timestamp, ta2.timestamp)
        ta = TimeArray(timestamps, zeros(length(timestamps), 0), String[], Void)
        ta = merge(ta, ta1, :left)
        ta = merge(ta, ta2, :left, meta=meta)

    else
        throw(ArgumentError(
            "merge method must be one of :inner, :left, :right, :outer"))
    end

    return setcolnames!(ta, colnames)

end

# collapse ######################

function collapse(ta::TimeArray{T, N, D}, period::Function, timestamp::Function,
                  value::Function=timestamp) where {T, N, D}

    length(ta) == 0 && return ta

    ncols = length(ta.colnames)
    collapsed_tstamps = D[]
    collapsed_values = ta.values[1:0, :]

    tstamp = ta.timestamp[1]
    mapped_tstamp = period(tstamp)
    cluster_startrow = 1

    for i in 1:length(ta)-1

        next_tstamp = ta.timestamp[i+1]
        next_mapped_tstamp = period(next_tstamp)

        if mapped_tstamp != next_mapped_tstamp
          push!(collapsed_tstamps, timestamp(ta.timestamp[cluster_startrow:i]))
          collapsed_values = [collapsed_values; T[value(ta.values[cluster_startrow:i, j]) for j in 1:ncols]']
          cluster_startrow = i+1
        end #if

        tstamp = next_tstamp
        mapped_tstamp = next_mapped_tstamp

    end #for

    push!(collapsed_tstamps, timestamp(ta.timestamp[cluster_startrow:end]))
    collapsed_values = [collapsed_values; T[value(ta.values[cluster_startrow:end, j]) for j in 1:ncols]']

    N == 1 && (collapsed_values = vec(collapsed_values))
    return TimeArray(collapsed_tstamps, collapsed_values, ta.colnames, ta.meta)

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
        if ta.colnames != prev_colnames
            throw(ArgumentError("column names don't match"))
        end
    end

    # Concatenate the contents.
    timestamps = vcat([ta.timestamp for ta in TA]...)
    values = vcat([ta.values for ta in TA]...)

    order = sortperm(timestamps)
    if length(TA[1].colnames) == 1 # Check for 1D to ensure values remains a 1D vector.
        return TimeArray(timestamps[order], values[order], TA[1].colnames, TA[1].meta)
    else
        return TimeArray(timestamps[order], values[order, :], TA[1].colnames, TA[1].meta)
    end
end

# map ######################

function map(f::Function, ta::TimeArray)
    timestamps = similar(ta.timestamp)
    values = similar(ta.values)

    for i in 1:length(ta)
        timestamps[i], values[i, :] = f(ta.timestamp[i], vec(ta.values[i, :]))
    end

    order = sortperm(timestamps)
    if length(ta.colnames) == 1 # Check for 1D to ensure values remains a 1D vector.
        return TimeArray(timestamps[order], values[order], ta.colnames, ta.meta)
    else
        return TimeArray(timestamps[order], values[order, :], ta.colnames, ta.meta)
    end
end
