
@recipe function f{T<:TimeArray}(ta::T)
    st = get(d, :seriestype, :path)
    if in(st, [:candlestick, :heikinashi])
        cs = Candlestick(ta)
        st == :heikinashi && HeikinAshi!(cs)

        seriestype := :candlestick
        legend --> false
        linewidth --> 0.7
        grid --> false

        bw = get(d, :bar_width, nothing)
        bw == nothing && (bw = 0.8)
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
        t = series .== 1
        if sum(t) > 0
            @series begin
                linecolor := :red
                fillcolor := :red
                fillto := cs.close[t]
                seriestype := :bar
                cs.time[t], cs.open[t]
            end

            @series begin
                primary := false
                linecolor := :red
                seriestype := :sticks
                fillto := cs.low[t]
                cs.time[t], cs.close[t]
            end

            @series begin
                primary := false
                linecolor := :red
                seriestype := :sticks
                fillto := cs.open[t]
                cs.time[t], cs.high[t]
            end
        end

        # close up, close < open
        t = series .== 2
        if sum(t) > 0
            @series begin
                linecolor := :blue
                fillcolor := :blue
                fillto := cs.close[t]
                seriestype := :bar
                cs.time[t], cs.open[t]
            end

            @series begin
                primary := false
                linecolor := :blue
                seriestype := :sticks
                fillto := cs.low[t]
                cs.time[t], cs.close[t]
            end

            @series begin
                primary := false
                linecolor := :blue
                seriestype := :sticks
                fillto := cs.open[t]
                cs.time[t], cs.high[t]
            end
        end

        # close down, close > open
        t = series .== 3
        if sum(t) > 0
            @series begin
                linecolor := :red
                fillalpha := 0
                linealpha := 1
                fillto := cs.open[t]
                seriestype := :bar
                cs.time[t], cs.close[t]
            end

            @series begin
                primary := false
                linecolor := :red
                seriestype := :sticks
                fillto := cs.low[t]
                cs.time[t], cs.open[t]
            end

            @series begin
                primary := false
                linecolor := :red
                seriestype := :sticks
                fillto := cs.close[t]
                cs.time[t], cs.high[t]
            end
        end

        # close down, close > open
        t = series .== 4
        if sum(t) > 0
            @series begin
                linecolor := :blue
                fillalpha := 0
                linealpha := 1
                fillto := cs.open[t]
                seriestype := :bar
                cs.time[t], cs.close[t]
            end

            @series begin
                primary := false
                linecolor := :blue
                seriestype := :sticks
                fillto := cs.low[t]
                cs.time[t], cs.open[t]
            end

            @series begin
                primary := false
                linecolor := :blue
                seriestype := :sticks
                fillto := cs.close[t]
                cs.time[t], cs.high[t]
            end
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

type Candlestick{D <: TimeType}
    time::Vector{D}
    open::AbstractVector
    high::AbstractVector
    low::AbstractVector
    close::AbstractVector
end

Candlestick(ta::TimeArray) = Candlestick(extract_ohlc(ta)...)

function extract_ohlc(ta::TimeArray)
    indices = [find(x->lowercase(x) == name, ta.colnames) for name in ["open", "high", "low", "close"]]
    minimum(length.(indices)) < 1 && error("The time array did not have variables named open, high, low and close")
    (ta.timestamp, [ta.values[:,i] for i in 1:4]...)
end

function HeikinAshi!(cs::Candlestick) #some values here are made too high!
    cs.close[1] = (cs.open[1] + cs.low[1] + cs.close[1] + cs.high[1]) / 4
    cs.open[1] = (cs.open[1] + cs.close[1])/2
    cs.high[1] = cs.high[1]
    cs.low[1] = cs.low[1]

    for i in 2:length(cs.open)
        cs.close[i] = (cs.open[i] + cs.low[i] + cs.close[i] + cs.high[i]) / 4
        cs.open[i] = (cs.open[i-1] + cs.close[i-1]) / 2
        cs.high[i] = maximum([cs.high[i], cs.open[i], cs.close[i]])
        cs.low[i] = minimum([cs.low[i], cs.open[i], cs.close[i]])
    end
end

@recipe function f(cs::Candlestick)
    show("line 48")
end
