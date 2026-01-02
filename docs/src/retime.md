# Retime

The `retime` function allows you to retime, i.e. change the timestamps of a `TimeArray`, similar to what [Matlab's retime](https://www.mathworks.com/help/matlab/ref/timetable.retime.html) does.

```@example retime
using Plots, Dates, TimeSeries
default(show = false)  # hide
ENV["GKSwstype"] = "100" # hide
gr()
timestamps = range(DateTime(2020, 1, 1), length = 7*24, step = Hour(1))
ta = TimeArray(timestamps, cumsum(randn(7*24)), [:a])
```

## Using a new time step
```@example retime
retime(ta, Minute(15))
```

## Using new timestep vector
```@example retime
new_timestamps = range(DateTime(2020, 1, 1), DateTime(2020, 1, 2), step = Minute(15))
retime(ta, new_timestamps)
```

## Irregular timestamps
You can perform retime on irregularly spaced timestamps, both using a `TimeArray` with irregular timestamps or using a vector of irregular timestamps. Depending on the timestamps `upsampling` or `downsampling` is used. 
```@example retime
new_timestamps = vcat(
    range(DateTime(2020, 1, 1), DateTime(2020, 1, 2)-Minute(15), step = Minute(15)), 
    range(DateTime(2020, 1, 2), DateTime(2020, 1, 3), step = Hour(1)),
)
retime(ta, new_timestamps)
```

## Upsampling

Interpolation is done using the `upsample` argument. If no data is directly hit, the specified `upsample` method is used. Available `upsample` methods are:
- `Linear()` or `:linear`
- `Nearest()` or `:nearest`
- `Previous()` or `:previous`
- `Next()` or `:next`

```@example retime
ta_ = retime(ta, Minute(15), upsample=Linear())
```

```@example retime
plot(ta)
plot!(ta_)
savefig("retime-upsampling.svg"); nothing # hide
```
![](retime-upsampling.svg)

## Downsampling

Downsampling or aggregation is done using the `downsample` argument. This applies a function to each interval not including the right-edge of the interval. If no data is present in the interval the specified `upsample` method is used.
Available `downsample` methods are:
- `Mean()` or `:mean`
- `Min()` or `:min`
- `Max()` or `:max`
- `Count()` or `:count`
- `Sum()` or `:sum`
- `Median()` or `:median`
- `First()` or `:first`
- `Last()` or `:last`

```@example retime
ta_ = retime(ta, Hour(6), downsample=Mean())
```

```@example retime
plot(ta)
plot!(ta_)
savefig("retime-downsample.svg"); nothing # hide
```
![](retime-downsample.svg)

## Extrapolation

Extrapolation at the beginning and end of the time series is done using the `extrapolate` argument. 
Available `extrapolate` methods are:
- `FillConstant(value)` or `:fillconstant`
- `NearestExtrapolate()` or `:nearest`
- `MissingExtrapolate()` or `:missing`
- `NaNExtrapolate()` or `:nan`

```@example retime
new_timestamps = range(DateTime(2019, 12, 31), DateTime(2020, 1, 2), step = Minute(15))
ta_ = retime(ta, new_timestamps, extrapolate=MissingExtrapolate())
```

## Interpolation Methods

Available interpolation methods: `Linear`, `Previous`, `Next`, `Nearest`.

## Aggregation Methods

Available aggregation methods: `Mean`, `Min`, `Max`, `Count`, `Sum`, `Median`, `First`, `Last`.

## Extrapolation Methods

Available extrapolation methods: `FillConstant`, `NearestExtrapolate`, `MissingExtrapolate`, `NaNExtrapolate`.
