
@recipe function f(ta::T) where {T<:TimeArray}
    st = get(plotattributes, :seriestype, :path)
    if in(st, [:candlestick, :heikinashi])
        Candlestick(ta)
    #elseif st == :ohlc #ohlc (meaning sticks with steps on the sides) should be passed on to Plots internal ohlc plot engine
    #    ta, ohlc = extract_ohlc(ta)
    #    collect(zip(ohlc)) # But there are currently issues with that
    else
        labels --> get(plotattributes, :label, reshape(String.(colnames(ta)),1,length(colnames(ta))))
        seriestype := st
        timestamp(ta), values(ta)
    end
end

# FIXME: refine Candlestick as a subtype of AbstractTimeSeries
#        it requires the Base.view supports. (#419)
"""
    Candlestick(ta::TimeArray)

# Argument

- There are four required columns from `ta::TimeArray`: `open`, `high`, `low` and
  `close`. The column names is case-insensitive.

# Examples

```julia-repl
julia> using MarketData

julia> TimeSeries.Candlestick(ohlcv)
```
"""
mutable struct Candlestick{D <: TimeType}
    time::Vector{D}
    open::AbstractVector
    high::AbstractVector
    low::AbstractVector
    close::AbstractVector
end

Candlestick(ta::TimeArray) = Candlestick(extract_ohlc(ta)...)

function extract_ohlc(ta::TimeArray)
    C     = ["open", "high", "low", "close"]
    cols  = colnames(ta)
    cols′ = lowercase.(string.(colnames(ta)))
    V     = map(C) do x
        i = findfirst(isequal(x), cols′)
        i ≡ nothing && throw(ArgumentError("the TimeArray did not have column `$x`"))
        values(ta[cols[i]])
    end
    (timestamp(ta), V...)
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
        inds = similar(cs.close, Int)
        inds[1] = att[:close_open](cs.close[1], cs.open[1]) & att[:close_prev](cs.close[1], cs.close[1])
        @. inds[2:end] = att[:close_open](cs.close[2:end], cs.open[2:end]) & att[:close_prev]($diff(cs.close), 0)
        inds = findall(Bool.(inds))

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
