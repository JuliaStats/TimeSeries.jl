###### update ####################

function update(ta::TimeArray{T, N, D}, tstamp::D, val::Array{T, N}) where {T, N, D}

    if length(ta) == 0
        error("updating empty time arrays is not supported, please use a scalable approach")
    elseif tstamp < maximum(ta.timestamp)
        error("only appending operations supported")
    else
        t    = vcat(ta.timestamp, tstamp)
        vals = vcat(ta.values, val)
        uta  = TimeArray(t, vals, ta.colnames, ta.meta)
    end
    uta
end

function update(ta::TimeArray{T, N, D}, tstamp::D, val::T) where {T, N, D}

    if length(ta) == 0
        error("updating empty time arrays is not supported, please use a scalable approach")
    elseif tstamp < maximum(ta.timestamp)
        error("only appending operations supported")
    else
        t    = vcat(ta.timestamp, tstamp)
        vals = vcat(ta.values, val)
        uta  = TimeArray(t, vals, ta.colnames, ta.meta)
    end
    uta
end

###### rename ####################

function rename(ta::TimeArray, colnames::Vector)
    TimeArray(ta.timestamp, ta.values, colnames, ta.meta)
end

function rename(ta::TimeArray, colnames::String)
    TimeArray(ta.timestamp, ta.values, [colnames], ta.meta)
end
