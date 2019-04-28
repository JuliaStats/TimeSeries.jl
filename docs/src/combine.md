# Combine methods

`TimeSeries` supports merging two `TimeArray`s, and squishing the timestamp
to a longer-term interval while representing values that make sense.

## `merge`

The `merge` method performs joins between two `TimeArray`s. The default
behaviour is to perform an inner join, such that the resulting `TimeArray`
contains only timestamps that both `TimeArray`s share, and values that
correspond to that timestamp.

The `AAPL` object from `MarketData` has 8,336 rows of data from Dec 12, 1980
to Dec 31, 2013. If we merge it with the `CAT` object, which contains
13,090 rows of data from Jan 2, 1962 to Dec 31, 2013 we might expect the
resulting `TimeArray` to have 8,336 rows of data, corresponding to the
length of `AAPL`. This assumes that every day that Apple Computer, Inc.
traded, Caterpillar, Inc likewise traded. It turns out that this isn't
true. `CAT` did not trade on Sep 27, 1985 because Hurricane Glorio shut
down the New York Stock Exchage. Apple Computer trades on the electronic
NASDAQ and its trading was not halted on that day. The result of the
merge should then be 8,335 rows:

```@repl merge
using TimeSeries
using MarketData
AppleCat = merge(AAPL,CAT);
length(AppleCat)
```

Left, right, and outer joins can also be performed by passing the
corresponding symbol. These joins introduce `NaN` values when data for a
particular timestamp only exists in one of the series to be merged. For
example:

```@repl merge
merge(op[1:3], cl[2:4], :left)
merge(op[1:3], cl[2:4], :right)
merge(op[1:3], cl[2:4], :outer)
```

The `merge` method allows users to specify the value for the `meta`
field of the merged object. When that value is not explicitly provided,
`merge` will concatenate the `meta` field values, assuming these values
to be strings. This covers the vast majority of use cases. In edge cases
when users do not provide a `meta` value and both field values are not
strings, the merged object will take on `Void` as its `meta` field
value:

```@repl merge
meta(AppleCat)
CatApple = merge(CAT, AAPL, meta=47);
meta(CatApple)
meta(merge(AppleCat, CatApple))
```

## `collapse`

The `collapse` method allows for compressing data into a larger time
frame. For example, converting daily data into monthly data. When
compressing dates, something rational has to be done with the values
that lived in the more granular time frame. To define what happens, a
function call is made. In our example, we want to compress the daily
`cl` closing prices from daily to monthly. It makes sense for us to take
the `last` value known and have that represented with the corresponding
timestamp. A non-exhaustive list of valid time methods is presented
below.

| Dates method | Time length |
|--------------|-------------|
| `day`        | daily       |
| `week`       | weekly      |
| `month`      | monthly     |
| `year`       | yearly      |

Showing this code in REPL:

```@repl collapse
using TimeSeries
using MarketData
collapse(cl,month,last)
```

We can also supply the function that chooses the timestamp and the
function that determines the corresponding value independently:

```@repl collapse
using Statistics
collapse(cl, month, last, mean)
```

## `vcat`

The `vcat` method is used to concatenate time series: if you have two
time series with the same columns, but two distinct periods of time,
this function can merge them into a single object. Notably, it can be
used to merge data that is split into multiple files. Its behaviour is
quite different from `merge`, which does not consider that its arguments
are actually the *same* time series.

This concatenation is *vertical* (`vcat`) because it does not create
columns, it extends existing ones (which are represented vertically).

For example:

```@repl
using TimeSeries
a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16])
b = TimeArray([Date(2015, 12, 01)], [17])
vcat(a,b)
[a; b] # same as vcat(a,b)
```

## `map`

This function allows complete transformation of the data within the time
series, with alteration on both the time stamps and the associated
values. It works exactly like `Base.map`: the first argument is a binary
function (the time stamp and the values) that returns two values,
respectively the new time stamp and the new vector of values. It does
not perform any kind of compression like `collapse`, but rather
transformations.

The simplest example is to postpone all time stamps in the given time
series, here by one year:

```@repl
using TimeSeries
using Dates
ta = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16])
map((timestamp, values) -> (timestamp + Year(1), values), ta)
```
