import Base.broadcast


# ND TimeArray <--> MD TimeArray
function broadcast(f, ta1::TimeArray, ta2::TimeArray)
    # first test metadata matches
    meta = ta1.meta == ta2.meta ? ta1.meta : Void

    # determine array widths and name cols accordingly
    w1, w2  = length(ta1.colnames), length(ta2.colnames)
    if w1 == w2
        cnames = [ta1.colnames[i] * "_" * ta2.colnames[i] for i = 1:w1]
    elseif w1 == 1
        cnames = [ta1.colnames[1] * "_" * ta2.colnames[i] for i = 1:w2]
    elseif w2 == 1
        cnames = [ta1.colnames[i] * "_" * ta2.colnames[1] for i = 1:w1]
    else
        error("arrays must have the same number of columns, or one must be a single column")
    end

    # obtain shared timestamp
    idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
    tstamp = ta1[idx1].timestamp

    # retrieve values that match the Int array matching dates
    vals1, vals2 = ta1[idx1].values, ta2[idx2].values

    # compute output values
    vals = broadcast(f, vals1, vals2)
    TimeArray(tstamp, vals, cnames, meta)
end

function broadcast(f, ta::TimeArray, args...)
    vals = broadcast(f, ta.values, args...)
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

# FIXME: How to deal with f(Number, Number, ..., TimeArray)?
function broadcast(f, n::Number, ta::TimeArray, args...)
    vals = broadcast(f, n, ta.values, args...)
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end
