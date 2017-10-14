
@recipe function f(ta::T) where {T<:TimeArray}
    st = get(plotattributes, :seriestype, :path)
    if in(st, [:candlestick, :heikinashi])
        Candlestick(ta)
    #elseif st == :ohlc #ohlc (meaning sticks with steps on the sides) should be passed on to Plots internal ohlc plot engine
    #    ta, ohlc = extract_ohlc(ta)
    #    collect(zip(ohlc)) # But there are currently issues with that
    else
        labels --> reshape(ta.colnames,1,length(ta.colnames))
        seriestype := st
        ta.timestamp, ta.values
    end
end

mutable struct Candlestick{D <: TimeType}
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

function HeikinAshi!(cs::Candlestick) # some values here are made too high!
    cs.close[1] = (cs.open[1] + cs.low[1] + cs.close[1] + cs.high[1]) / 4
    cs.open[1] = (cs.open[1] + cs.close[1]) / 2
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
    st = get(plotattributes, :seriestype, :candlestick)
    st == :heikinashi && HeikinAshi!(cs)

    seriestype := :scatter #ignored
    legend --> false
    linewidth --> 0.7
    grid --> false

    bw = get(plotattributes, :bar_width, nothing)
    bw == nothing && (bw = 0.8)
    bar_width := bw / 2 * minimum(diff(unique(Dates.value.(cs.time))))

    # allow passing alternative colors as a vector
    cols = get(plotattributes, :seriescolor, nothing)
    cols = (isa(cols, Vector{Symbol}) && length(cols) == 2) ? cols : [:red, :blue]

    attributes = [
        Dict(:close_open => <,
             :close_prev => <,
             :bottombox => cs.close,
             :topbox => cs.open,
             :fill => cols[1],
             :line => cols[1],
             :fillalpha => 1),
        Dict(:close_open =>
             <, :close_prev => >=,
             :bottombox => cs.close,
             :topbox => cs.open,
             :fill => cols[2],
             :line => cols[2],
             :fillalpha => 1),
        Dict(:close_open => >=,
             :close_prev => <,
             :bottombox => cs.open,
             :topbox => cs.close,
             :fill => :white,
             :line => cols[1],
             :fillalpha => 0),
        Dict(:close_open => >=,
             :close_prev => >=,
             :bottombox => cs.open,
             :topbox => cs.close,
             :fill => :white,
             :line => cols[2],
             :fillalpha => 0)
    ]


    for att in attributes
        inds = Vector{Int}(length(cs.close))
        inds[1] = att[:close_open](cs.close[1], cs.open[1]) & att[:close_prev](cs.close[1], cs.close[1])
        @. inds[2:end] = att[:close_open](cs.close[2:end], cs.open[2:end]) & att[:close_prev]($diff(cs.close), 0)
        inds = find(inds)

        if length(inds) > 0
            @series begin
                linecolor := att[:line]
                fillcolor := att[:fill]
                fillalpha := att[:fillalpha]
                fillto := att[:bottombox][inds]
                seriestype := :bar
                cs.time[inds], att[:topbox][inds]
            end

            for j in 1:2
                @series begin
                    primary := false
                    linecolor := att[:line]
                    seriestype := :sticks
                    fillto := j == 1 ? cs.low[inds] : att[:topbox][inds]
                    cs.time[inds], j == 1 ? att[:bottombox][inds] : cs.high[inds]
                end
            end
        end
    end
end
