###### update ####################

function update{T,N,D}(ta::TimeArray{T,N,D}, tstamp::D, val::Array{T,N})

    if length(ta) == 0
        #uta = TimeArray(tstamp, val, ta.colnames, ta.meta)
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

function update{T,N,D}(ta::TimeArray{T,N,D}, tstamp::D, val::T)

    if length(ta) == 0
#        uta = TimeArray(tstamp, [val], ta.colnames, ta.meta)
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

function rename{T,N,D}(ta::TimeArray{T,N,D}, colnames::Vector)
    TimeArray(ta.timestamp, ta.values, colnames, ta.meta)
end

function rename{T,N,D}(ta::TimeArray{T,N,D}, colnames::String)
    TimeArray(ta.timestamp, ta.values, [colnames], ta.meta)
end
