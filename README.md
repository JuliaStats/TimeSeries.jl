[![Build Status](https://travis-ci.org/JuliaStats/TimeSeries.jl.png)](https://travis-ci.org/JuliaStats/TimeSeries.jl)

#### Installation

````julia
julia> Pkg.add("TimeSeries")
````
The TimeSeries package depends on DataFrames and Datetime packages. 
#### Demonstration

We'll read in some stock price data from the `test/data` directory inside the package.
The `readtime` function calls the `readtable` function from DataFrames to do the heavy
lifting in parsing out a csv file. It currently parses any `UTF8String` column that can 
be parsed by the Datetime package into a `Date{ISOCalendar}` type. The `readtime` function
also enforces that the oldest record goes into the first row. 

````julia
julia> using TimeSeries

julia> spx = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))

julia> head(spx, 3)
3x7 DataFrame:
              Date  Open  High   Low Close   Volume Adj Close
[1,]    1970-01-02 92.06 93.54 91.79  93.0  8050000      93.0
[2,]    1970-01-05  93.0 94.25 92.53 93.46 11490000     93.46
[3,]    1970-01-06 93.46 93.81 92.13 92.82 11460000     92.82
````

When dealing with time series data, it is often useful to lag or lead data. This
is done with the `lag` and `lead` functions. The `lag` function allows negative
integers, in which case it simply calls the `lead` function. The bang version `!`
modifies the existing DataFrame. 

````julia
julia> head(lag!(spx, "Close"), 3)
3x8 DataFrame:
              Date  Open  High   Low Close   Volume Adj Close Close_lag_1
[1,]    1970-01-02 92.06 93.54 91.79  93.0  8050000      93.0          NA
[2,]    1970-01-05  93.0 94.25 92.53 93.46 11490000     93.46        93.0
[3,]    1970-01-06 93.46 93.81 92.13 92.82 11460000     92.82       93.46
````
Other important functions include the `moving` function, which calculates data within
a rolling window of consecutive rows of data, `upto`, which calculates all the data from
the beginning to the current row, and two `returns` functions that calculate the percent
change in a value between rows (simple and logarithmic are available).

The `bydate.jl` file includes functions that aggregate a DataFrame whose first row is a `Date{ISOCalendar}`
type and does so along a specified time period. `bymonth` for example will aggregate rows whose month
value is whatever is specified in the function call. 

If you're interested in running the test suite, you can call the `@timeseries` macro inside a Julia session.

````julia
julia> @timeseries

Running tests:
**   test/bydate.jl
**   test/io.jl
**   test/lag.jl
**   test/moving.jl
**   test/returns.jl
**   test/upto.jl
````

#### Documentation

Online documentation, including an API reference, is planned.

See the [online documentation](http://juliastats.github.io/TimeSeries.jl/) 
