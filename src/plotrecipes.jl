# basic plotting
@recipe function f{T<:TimeArray}(ta::T)
    st = get(d, :seriestype, :path)
    in(st, [:candlestick, :heikinashi]) && return Candlestick(ta)

    if st == :ohlc #ohlc is passed on to Plots internal ohlc plot engine
        ta, ohlc = extract_ohlc(ta)
        return collect(zip(ohlc)) # the time component is dropped - this is how it is currently implemented in Plots but should be fixed
    end
    labels --> reshape(ta.colnames,1,length(ta.colnames))
    seriestype := st
    ta.timestamp, ta.values
end

#--------------------------------
# Plotting of candlesticks for OHLC data

type Candlestick
    times::Vector{DateTime}
    open::Vector{Float64}
    low::Vector{Float64}
    high::Vector{Float64}
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

    for i in 2:length(cs.times)
        cs.close[i] = (cs.open[i] + cs.low[i] + cs.close[i] + cs.high[i]) / 4
        cs.open[i] = (cs.open[i-1] + cs.close[i-1])
        cs.high[i] = maximum(cs.high[i], cs.open[i], cs.close[i])
        cs.low[i] = minimum(cs.low[i], cs.open[i], cs.close[i])
    end
end

@recipe function f(cs::Candlestick)
    show("line 48")
    d[:seriestype] == :heikinashi && HeikinAshi!(cs)
    seriestype := :candlestick
    len = length(cs.open)
    series = Vector{Int}(len)
    series[1] = close[1] >= open[1] ? 3 : 1

    # create four series
    for i in 2:len
        fil = 2*(close[i] >= open[i])
        col = 1 + (close[i] >= close[i-1])
        series[i] = col + fil
    end

    # close low, close < open
    @series begin
        fillcolor = :red
        linecolor = :red
        t = series .== 1
        # collect in one vector be able to use a series recipe
        [cs.time[t]; cs.time[t]; cs.time[t]; cs.time[t]], [cs.open[t]; cs.high[t]; cs.low[t]; cs.close[t]]
    end

        # close up, close < open
    @series begin
        fillcolor = :blue
        linecolor = :blue
        t = series .== 2
        [cs.time[t]; cs.time[t]; cs.time[t]; cs.time[t]], [cs.open[t]; cs.high[t]; cs.low[t]; cs.close[t]]
    end

        # close down, close > open
    @series begin
        fillalpha = 0
        linecolor = :red
        t = series .== 3
        [cs.time[t]; cs.time[t]; cs.time[t]; cs.time[t]], [cs.close[t]; cs.high[t]; cs.low[t]; cs.open[t]]
    end

        # close down, close > open
    @series begin
        fillalpha = 0
        linecolor = :blue
        t = series .== 4
        [cs.time[t]; cs.time[t]; cs.time[t]; cs.time[t]], [cs.close[t]; cs.high[t]; cs.low[t]; cs.open[t]]
    end
end

@recipe function f(::Type{Val{:candlestick}}, x, y, z)
    # and split them apart again
    len = Int(length(x)/4)
    time = x[1:len]
    topbox = y[1:len]
    top = y[(len + 1):(2len)]
    bottom = y[(2len + 1):(3len)]
    bottombox = y[(3len + 1):end]

    xsegs, ysegs = Segments(), Segments()
    bw = get(d, :bar_width, 0.8)
    for (i, ti) in enumerate(time)
        l, m, r = ti - bw, ti, ti + bw
        push!(xsegs, m, m, m) # upper shadow
        push!(xsegs, l, l)    # left side
        push!(xsegs, m, m, m) # lower shadow
        push!(xsegs, r, r, m) # right side

        push!(ysegs, topbox, top, topbox)            # upper shadow
        push!(ysegs, topbox, bottombox)              # left side
        push!(ysegs, bottombox, bottom, bottombox)   # lower shadow
        push!(ysegs, bottombox, topbox, topbox)      # right side
    end

    seriestype := :shape
    x := xsegs.pts
    y := ysegs.pts
    ()
end
