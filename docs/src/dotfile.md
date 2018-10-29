# Customize `TimeArray` printing

A dot file named `.timeseriesrc` sets three variables that control how
`TimeArrays` are displayed. This doesn't change the underlying `TimeArray`
and only controls how values are printed to REPL.

Here is an handy way to edit it:

```julia
julia> using TimeSeries

julia> edit(joinpath(dirname(pathof(TimeSeries)), ".timeseriesrc.jl"))
```

## `DECIMALS`

`DECIMALS = 4`

The default setting is 4. It shows values out to four decimal places:

```@repl
using TimeSeries
using MarketData
percentchange(cl)
```

You can change it to whatever value you prefer. If you change it to 6,
the same transformation will display like this:

```julia
julia> percentchange(cl)
499x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2001-12-31
│            │ Close     │
├────────────┼───────────┤
│ 2000-01-04 │ -0.084331 │
│ 2000-01-05 │ 0.014634  │
│ 2000-01-06 │ -0.086538 │
│ 2000-01-07 │ 0.047368  │
│ 2000-01-10 │ -0.017588 │
│ 2000-01-11 │ -0.051151 │
│ 2000-01-12 │ -0.059946 │
│ 2000-01-13 │ 0.109646  │
│ 2000-01-14 │ 0.03814   │
   ⋮
│ 2001-12-19 │ 0.029034  │
│ 2001-12-20 │ -0.043941 │
│ 2001-12-21 │ 0.015965  │
│ 2001-12-24 │ 0.017143  │
│ 2001-12-26 │ 0.006086  │
│ 2001-12-27 │ 0.026989  │
│ 2001-12-28 │ 0.016312  │
│ 2001-12-31 │ -0.023629 │
```

## `MISSING`

This output is controlled with `const` values to accommodate difficult to
remember unicode numbers:

```julia
const NAN       = "NaN"
const NA        = "NA"
const BLACKHOLE = "\u2B24"
const DOTCIRCLE = "\u25CC"
const QUESTION  = "\u003F"

MISSING = NAN
```

The default setting displays `NaN`, which represent the actual value
when `padding=true` is selected for certain transformations. You can
change it to show differently with the provided `const` values or roll
your own. Dot files are often used to customize your experience, so have
at it!

Here is an example in REPL with the default:

```julia
julia> lag(cl, padding=true)
500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ NaN    │
│ 2000-01-04 │ 111.94 │
│ 2000-01-05 │ 102.5  │
│ 2000-01-06 │ 104.0  │
│ 2000-01-07 │ 95.0   │
│ 2000-01-10 │ 99.5   │
│ 2000-01-11 │ 97.75  │
│ 2000-01-12 │ 92.75  │
│ 2000-01-13 │ 87.19  │
   ⋮
│ 2001-12-19 │ 21.01  │
│ 2001-12-20 │ 21.62  │
│ 2001-12-21 │ 20.67  │
│ 2001-12-24 │ 21.0   │
│ 2001-12-26 │ 21.36  │
│ 2001-12-27 │ 21.49  │
│ 2001-12-28 │ 22.07  │
│ 2001-12-31 │ 22.43  │
```

Here is an example in REPL with `NA` selected:

```julia
julia> lag(cl, padding=true)
500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ NA     │
│ 2000-01-04 │ 111.94 │
│ 2000-01-05 │ 102.5  │
│ 2000-01-06 │ 104.0  │
│ 2000-01-07 │ 95.0   │
│ 2000-01-10 │ 99.5   │
│ 2000-01-11 │ 97.75  │
│ 2000-01-12 │ 92.75  │
│ 2000-01-13 │ 87.19  │
   ⋮
│ 2001-12-19 │ 21.01  │
│ 2001-12-20 │ 21.62  │
│ 2001-12-21 │ 20.67  │
│ 2001-12-24 │ 21.0   │
│ 2001-12-26 │ 21.36  │
│ 2001-12-27 │ 21.49  │
│ 2001-12-28 │ 22.07  │
│ 2001-12-31 │ 22.43  │
```

Here is an example in REPL with `BLACKHOLE` selected:

```julia
julia> lag(cl, padding=true)
500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ ⬤     │
│ 2000-01-04 │ 111.94 │
│ 2000-01-05 │ 102.5  │
│ 2000-01-06 │ 104.0  │
│ 2000-01-07 │ 95.0   │
│ 2000-01-10 │ 99.5   │
│ 2000-01-11 │ 97.75  │
│ 2000-01-12 │ 92.75  │
│ 2000-01-13 │ 87.19  │
   ⋮
│ 2001-12-19 │ 21.01  │
│ 2001-12-20 │ 21.62  │
│ 2001-12-21 │ 20.67  │
│ 2001-12-24 │ 21.0   │
│ 2001-12-26 │ 21.36  │
│ 2001-12-27 │ 21.49  │
│ 2001-12-28 │ 22.07  │
│ 2001-12-31 │ 22.43  │
```

Other `const` values include `DOTCIRCLE` and `QUESTION`.
The `UNICORN` value is a feature request.
