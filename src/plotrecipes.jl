
@recipe function f(ta::T) where {T<:TimeArray}
    seriestype --> :path

    st = plotattributes[:seriestype]
    if st ∈ [:candlestick, :heikinashi]
        Candlestick(ta)
    else
        label --> reshape(string.(colnames(ta)), 1, :)
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

    legend    --> false
    linewidth --> 0.5
    grid      --> true

    bw = get(plotattributes, :bar_width, 0.9)

    # allow passing alternative colors as a vector
    cols = get(plotattributes, :seriescolor, [:green, :red])
    if !(cols isa Vector{Symbol}) || length(cols) != 2
        throw(ArgumentError(":seriescolor should be a Vector{Symbol} of two elements."))
    end

    xseg, yseg = Float64[], Float64[]
    idx = 1:length(cs.time)
    colors = similar(idx, Symbol)
    margin = (1 - bw) / 2
    for (i, o, h, l, c) ∈ zip(idx, cs.open, cs.high, cs.low, cs.close)
        x₁, x₂ = i - 1 + margin, i - margin
        x̄ = i - 0.5
        append!(xseg, [
            x̄,
            x̄,
            x₁,
            x₁,
            x̄,
            x̄,
            x̄,
            x₂,
            x₂,
            x̄,
            NaN
        ])

        y₁, y₂ = min(o, c), max(o, c)
        append!(yseg, [
            l,
            y₁,
            y₁,
            y₂,
            y₂,
            h,
            y₂,
            y₂,
            y₁,
            y₁,
            NaN
        ])

        colors[i] = ifelse(o ≤ c, cols[1], cols[2])
    end

    @series begin
        seriestype  := :shape
        seriescolor := colors
        xticks      := (idx .- 0.5, string.(cs.time))
        xrotation   := 90
        xseg, yseg
    end
end
