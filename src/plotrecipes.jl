
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
    xrotation --> 90

    bw = get(plotattributes, :bar_width, 0.9)

    # allow passing alternative colors as a vector
    cols = get(plotattributes, :seriescolor, [:green, :red])
    if !(cols isa Vector{Symbol}) || length(cols) != 2
        throw(ArgumentError(":seriescolor should be a Vector{Symbol} of two elements."))
    end

    xseg, yseg = Vector{Float64}[], Vector{Float64}[]
    xcenter, ycenter = Float64[], Float64[]

    idx  = 1:length(cs.time)
    tick = 1

    colors = Symbol[]
    hovers = String[]
    margin = (1 - bw) / 2 * tick
    for (i, o, h, l, c) ∈ zip(idx, cs.open, cs.high, cs.low, cs.close)
        x₁, x₂ = i - tick + margin, i - margin
        x̄ = i - tick / 2
        push!(xseg, [
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
        ])

        y₁, y₂ = min(o, c), max(o, c)
        push!(yseg, [
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
        ])

        push!(colors, ifelse(o ≤ c, cols[1], cols[2]))

        push!(xcenter, x̄)
        push!(ycenter, (o + c) / 2)
        push!(hovers, "Open: $o<br>High: $h<br>Low: $l<br>Close: $c")
    end

    xticks = get(plotattributes, :xticks, 1)
    if xticks isa Integer
        if xticks != 1
            xticks := (idx .- 0.5, map(x -> (x % xticks) != 1 ? "" : string(cs.time[x]) ,idx))
        else
            xticks := (idx .- 0.5, string.(cs.time))
        end
    end

    # tweak the hover function for Plotly backend
    extract_plot_kwargs = get(plotattributes, :extract_plot_kwargs, Dict{Symbol,Any}())
    get!(extract_plot_kwargs, :hovermode, :x)
    get!(extract_plot_kwargs, :hoverdistance, 5)

    colors′ = reshape(colors, 1, :)

    @series begin
        seriestype  := :shape
        seriescolor := colors′
        linecolor  --> colors′
        label --> ""
        xseg, yseg
    end

    @series begin
        seriestype        := :scatter
        seriescolor       := colors
        markersize        := 1
        markerstrokewidth := 0
        label --> ""
        hover             --> hovers
        xcenter, ycenter
    end
end
