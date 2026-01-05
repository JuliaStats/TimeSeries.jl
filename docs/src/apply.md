# Apply methods

Common transformation of time series data involves lagging, leading,
calculating change, windowing operations and aggregation operations.
Each of these methods include keyword arguments that include defaults.

## `lag`

The `lag` method simply described is putting yesterday's value in
today's timestamp. This is the most common use case, though there are
many times the distance between timestamps is not 1 time unit. An
arbitrary integer distance for lagging is supported, with the default
equal to 1.

The value of the `cl` object on Jan 3, 2000 is 111.94. On Jan 4, 2000 it
is 102.50 and on Jan 5, 2000 it's 104.0:

```@repl lag
using MarketData
cl[1:3]
```

The `lag` method **moves** values up one day:

```@repl lag
lag(cl[1:3])
```

You will notice that since there is no known value for lagging the first
day, the observation on that timestamp is omitted. This behavior is
common in time series. When observations are consumed in a
transformation, the artifact dates are not preserved with a missingness
value. To pad the returned `TimeArray` with `NaN` values instead, you can
pass `padding=true` as a keyword argument:

```@repl lag
lag(cl[1:3]; padding=true)
```

## `lead`

Leading values operates similarly to lagging values, but moves things in
the other direction. Arbitrary time distances is also supported:

```@repl lead
using TimeSeries
using MarketData
lead(cl[1:3])
```

Since we are leading an object of length 3, only two values will be
transformed because we have lost a day to the transformation.

The `cl` object is 500 rows long so if we lead by 499 days, we should
put the last observation in the object (which happens to be on Dec 31, 2001)
into the first date's value slot:

```@repl lead
lead(cl, 499)
```

## `diff`

Differentiating a time series calculates the finite difference between
two consecutive points in the time series. The resulting time series
will have less points than the original. Those points are filled with
`NaN` values if `padding=true`.

```@repl diff
using TimeSeries
using MarketData
diff(cl)
```

You can calculate higher order differences by using the keyword
parameter `differences`, accepting a positive integer. The default
value is `differences=1`. For instance, passing `differences=2` is
equivalent to doing `diff(diff(cl))`.

## `percentchange`

Calculating change between timestamps is a very common time series
operation. We use the terms percent change, returns and rate of change
interchangably. Depending on which domain you're using time series, you
may prefer one name over the other.

This package names the function that performs this transformation
`percentchange`. You're welcome to change this of course if that
represents too many letters for you to type:

```@repl percentchange
using TimeSeries
roc = percentchange
```

The `percentchange` method includes the option to return a simple return
or a log return. The default is set to `simple`:

```@repl percentchange
using MarketData
percentchange(cl)
```

Log returns are popular for downstream calculations since adding returns
is simpler than multiplying them. To create log returns, pass the symbol
`:log` to the method:

```@repl percentchange
percentchange(cl, :log)
```

## `moving`

Often when working with time series, you want to take a sliding window
view of the data and perform a calculation on it. The simplest example
of this is the moving average. For a 10-period moving average, you take
the first ten values, sum then and divide by 10 to get their average.
Then you slide the window down one and to the same thing. This operation
involves two important arguments: the function that you want to use on
your window and the size of the window you want to apply that function
over.

In our moving average example, we would pass arguments this way:

```@repl
using TimeSeries
using MarketData
using Statistics
moving(mean, cl, 10)
```

As mentioned previously, we lose the first nine observations to the
consuming nature of this operation. They are not **missing** per se,
they simply do not exist.

## `upto`

Another operation common in time series analysis is an aggregation
function. `TimeSeries` supports this with the `upto` method. Suppose you
want to keep track of the sum of all the values from the beginning to
the present timestamp. You would use the `upto` method like this:

```@repl
using TimeSeries
using MarketData
upto(sum, cl)
```

## `basecall`

Because the algorithm for the `upto` method needs to be
optimized further, it might be better to use a base method in its place
when one is available. Taking our summation example above, we could
instead use the `basecall` method and realize substantial performance
improvements:

```@repl
using TimeSeries
using MarketData
basecall(cl, cumsum)
```

## `uniformspaced` and `uniformspace`

These methods check or enforce uniform spacing in time series.

## `dropnan`

Removes rows containing NaN values from a TimeArray.
