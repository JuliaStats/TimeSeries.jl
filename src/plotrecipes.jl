
@recipe function f{T<:TimeArray}(ta::T)
    st = get(d, :seriestype, :path)
    if in(st, [:candlestick, :heikinashi])
        cs = Candlestick(ta)
        d[:seriestype] == :heikinashi && HeikinAshi!(cs)
        seriestype := :candlestick
        legend --> false
        linewidth --> 0.5

        bw = get(d, :bar_width, nothing)
        bw == nothing && (bw = 0.6)
        bar_width := bw / 2 * minimum(diff(unique(Int.(cs.time))))

        len = length(cs.open)
        series = Vector{Int}(len)
        series[1] = cs.close[1] >= cs.open[1] ? 3 : 1

        # create four series
        for i in 2:len
            fil = 2*(cs.close[i] >= cs.open[i])
            col = 1 + (cs.close[i] >= cs.close[i-1])
            series[i] = col + fil
        end

        # close low, close < open
        @series begin
            seriescolor := :red
            fillcolor := :red
            t = series .== 1
            # collect in one vector be able to use a series recipe
            cs.time[t], [cs.open[t]; cs.high[t]; cs.low[t]; cs.close[t]]
        end

            # close up, close < open
        @series begin
            seriescolor := :blue
            fillcolor := :blue
            t = series .== 2
            cs.time[t], [cs.open[t]; cs.high[t]; cs.low[t]; cs.close[t]]
        end

            # close down, close > open
        @series begin
            fillalpha := 0
            seriescolor := :red
            t = series .== 3
            cs.time[t], [cs.close[t]; cs.high[t]; cs.low[t]; cs.open[t]]
        end

            # close down, close > open
        @series begin
            fillalpha := 0
            seriescolor := :blue
            t = series .== 4
            cs.time[t], [cs.close[t]; cs.high[t]; cs.low[t]; cs.open[t]]
        end

    elseif st == :ohlc #ohlc is passed on to Plots internal ohlc plot engine
        ta, ohlc = extract_ohlc(ta)
        collect(zip(ohlc)) # the time component is dropped - this is how it is currently implemented in Plots but should be fixed
    else
        labels --> reshape(ta.colnames,1,length(ta.colnames))
        seriestype := st
        ta.timestamp, ta.values
    end
end

type Candlestick
    time::Vector{DateTime}
    open::Vector{Float64}
    high::Vector{Float64}
    low::Vector{Float64}
    close::Vector{Float64}
end

Candlestick(ta::TimeArray) = Candlestick(extract_ohlc(ta)...)

function extract_ohlc(ta::TimeArray)
    indices = [find(x->lowercase(x) == name, ta.colnames) for name in ["open", "high", "low", "close"]]
    minimum(length.(indices)) < 1 && error("The time array did not have variables named open, high, low and close")
    (ta.timestamp, [ta.values[:,i] for i in 1:4]...)
end

function HeikinAshi!(cs::Candlestick)
    cs.close[1] = (cs.open[1] + cs.low[1] + cs.close[1] + cs.high[1]) / 4
    cs.open[1] = (cs.open[1] + cs.close[1])/2
    cs.high[1] = cs.high[1]
    cs.low[1] = cs.low[1]

    for i in 2:length(cs.time)
        cs.close[i] = (cs.open[i] + cs.low[i] + cs.close[i] + cs.high[i]) / 4
        cs.open[i] = (cs.open[i-1] + cs.close[i-1])
        cs.high[i] = maximum([cs.high[i], cs.open[i], cs.close[i]])
        cs.low[i] = minimum([cs.low[i], cs.open[i], cs.close[i]])
    end
end

@recipe function f(cs::Candlestick)
    show("line 48")
end

@recipe function f(::Type{Val{:candlestick}}, x, y, z)
    # and split them apart again
    len = Int(length(y)/4)
    time = x
    topbox = y[1:len]
    top = y[(len + 1):(2len)]
    bottom = y[(2len + 1):(3len)]
    bottombox = y[(3len + 1):end]

    xsegs, ysegs = Vector{eltype(time)}(), Vector{eltype(top)}()
    bw = get(d, :bar_width, 1)

 #    for (i, ti) in enumerate(time)
 #        l, m, r = ti - bw, ti, ti + bw
 #        t, tb, b, bb = top[i], topbox[i], bottom[i], bottombox[i]
 #
 # # the last m is standin for at NaN value
 #        push!(xsegs, m, m, m)       # upper shadow
 #        push!(xsegs, m, l, m)       # left top of box
 #        push!(xsegs, l, l, m)       # left side
 #        push!(xsegs, l, m, m)       # left bottom
 #        push!(xsegs, m, m, m, m, m) # lower shadow
 #        push!(xsegs, m, r, m)       # right bottom
 #        push!(xsegs, r, r, m)       # right side
 #        push!(xsegs, r, m, m)       # right top of box
 #        #push!(xsegs, m, m, l, l, m, m, r, r, m, m, m, NaN)
 #        #push!(ysegs, t, tb, tb, bb, bb, b, bb, bb, tb, tb, t, NaN, NaN)
 #
 #        push!(ysegs, t, tb, NaN)       # upper shadow
 #        push!(ysegs, tb, tb, NaN)       # left top of box
 #        push!(ysegs, tb, bb, NaN)       # left side
 #        push!(ysegs, bb, bb, NaN)       # left bottom
 #        push!(ysegs, bb, b, b, bb, NaN) # lower shadow
 #        push!(ysegs, bb, bb, NaN)       # right bottom
 #        push!(ysegs, bb, tb, NaN)       # right side
 #        push!(ysegs, tb, tb, NaN)       # right top of box
 #    end
 #
 #    seriestype := :shape
 #    x := xsegs
 #    y := ysegs
 #    ()
end
