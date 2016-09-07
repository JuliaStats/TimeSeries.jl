###### update ####################

function update{T,N,D}(ta::TimeArray{T,N,D}, tstamp::D, val::Vector{T})
    if tstamp < maximum(ta.timestamp)
        error("only appending operations supported")
    else
        t    = vcat(ta.timestamp, tstamp)
        vals = vcat(ta.values, val')
    end
    TimeArray(t, vals, ta.colnames, ta.meta)
end

function update{T,N,D}(ta::TimeArray{T,N,D}, tstamp::D, val::T)
    if tstamp < maximum(ta.timestamp)
        error("only appending operations supported")
    else
        t    = vcat(ta.timestamp, tstamp)
        vals = vcat(ta.values, val)
    end
    TimeArray(t, vals, ta.colnames, ta.meta)
end

###### rename ####################

function rename{T,N,D}(ta::TimeArray{T,N,D}, colnames::Vector)
    TimeArray(ta.timestamp, ta.values, colnames, ta.meta)
end

function rename{T,N,D}(ta::TimeArray{T,N,D}, colnames::String)
    TimeArray(ta.timestamp, ta.values, [colnames], ta.meta)
end
