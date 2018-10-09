###### update ####################

function update(ta::TimeArray{T, N, D}, tstamp::D, val::Array{T, N}) where {T, N, D}

    if length(ta) == 0
        throw(ArgumentError(
            "updating empty time arrays is not supported, " *
            "please use a scalable approach"))
    elseif tstamp < maximum(timestamp(ta))
        throw(ArgumentError("only appending operations supported"))
    else
        t    = vcat(timestamp(ta), tstamp)
        vals = vcat(values(ta), val)
        uta  = TimeArray(t, vals, colnames(ta), meta(ta))
    end
    uta
end

function update(ta::TimeArray{T, N, D}, tstamp::D, val::T) where {T, N, D}

    if length(ta) == 0
        throw(ArgumentError(
            "updating empty time arrays is not supported, " *
            "please use a scalable approach"))
    elseif tstamp < maximum(timestamp(ta))
        throw(ArgumentError("only appending operations supported"))
    else
        t    = vcat(timestamp(ta), tstamp)
        vals = vcat(values(ta), val)
        uta  = TimeArray(t, vals, colnames(ta), meta(ta))
    end
    uta
end

###### rename ####################

# TODO: apply `unchecked`

rename(ta::TimeArray, colnames::Vector{Symbol}) =
    TimeArray(timestamp(ta), values(ta), colnames, meta(ta))

rename(ta::TimeArray, colnames::Symbol) =
    TimeArray(timestamp(ta), values(ta), [colnames], meta(ta))
