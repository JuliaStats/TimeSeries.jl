function compress{T,N,D}(ta::TimeArray{T,N,D}, interval::Int, timestamp::Function=last, value::Function=timestamp)
    
    len = length(ta) - (length(ta) % interval)

    t = D[]

    for ts in 1:interval:len
        push!(t, timestamp(ta.timestamp[ts:ts+interval-1]))
    end

    return t

    v = T[]

    for vs in 1:interval:len
        push!(v, value(ta.values[vs:vs+interval-1, :]))
    end

    TimeArray(t, v, ta.colnames, ta.meta)
end
