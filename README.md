For the demonstration, we'll be importing data from Yahoo with the `TradingInstrument` package.

#### Demonstration

````julia
julia> using TradingInstrument

julia> using TimeSeries

julia> AAPL = yahoo("AAPL");

julia> head(AAPL, 3)
3x7 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj
[1,]    2010-01-12 209.19 209.77 206.42 207.72 21230700  204.7
[2,]    2010-01-13 207.87 210.93  204.1 210.65 21639000 207.59
[3,]    2010-01-14 210.11 210.46 209.02 209.43 15460500 206.38
````

When dealing with time series data, it is often useful to lag or lead data. This
is done with the `lag` and `lead` functions. The `lag` function allows negative
integers, in which case it simply calls the `lead` function.

````julia
julia> head(lag!(AAPL,"Close"), 3)
3x8 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj Close_lag_1
[1,]    2010-01-12 209.19 209.77 206.42 207.72 21230700  204.7          NA
[2,]    2010-01-13 207.87 210.93  204.1 210.65 21639000 207.59      207.72
[3,]    2010-01-14 210.11 210.46 209.02 209.43 15460500 206.38      210.65

````
Other important functions include the `moving` function, which calculates data within
a rolling window of consecutive rows of data, `upto`, which calculates all the data from
the beginning to the current row, and two `returns` functions that calculate the percent
change in a value between rows (simple and logarithmic are available).

The `indexdate.jl` file includes functions that aggregate a DataFrame whose first row is a `Calendar`
type and does so along a specified time period. `indexmonth` for example will aggregate rows whose month
value is whatever is specified in the function call. 

If you're interested in running the test suite, you can call the `@timeseries` macro inside a Julia session.

````julia
julia> @timeseries

Running tests: 
**   test/returns.jl
**   test/lag.jl
**   test/moving.jl
**   test/upto.jl
**   test/indexdate.jl
````
NOTE: the `read_yahoo` function has been moved to the `TradingInstrument` package, but a version of it is still in this package 
for testing purposes.
