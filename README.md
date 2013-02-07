A toolkit of Julia functions for common time series transformations including:
lagging data, calculating moving values, calculating returns (both simple and log), 
sorting by day-of-week and downloading financial time series from Yahoo.
 
#### Demonstration

````julia
julia> using Thyme

julia> AAPL = read_yahoo("AAPL"); #defaults to the last three years daily

julia> # AAPL = yip("AAPL") #alias that does the same thing with less typing

julia> head(AAPL, 3)
3x7 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj
[1,]    2010-02-01 192.37  196.0  191.3 194.73 26781300 193.02
[2,]    2010-02-02 195.91 196.32 193.38 195.86 24940800 194.14
[3,]    2010-02-03 195.17  200.2 194.42 199.23 21976000 197.48
````

Include simple returns, an equity curve and a moving skewness over 30 periods.

````julia
julia> simple_return!(AAPL, "Adj"); #try sips for an alias to simple_return!

julia> equity!(AAPL, "Adj");

julia> moving!(AAPL, "Adj", skewness, 30);

julia> tail(AAPL)
6x10 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj     Adj_RET Adj_equity skewness_30
[1,]    2013-01-23 508.81 514.99 504.77 514.01 30768200 514.01   0.0183054    2.66299   -0.134034
[2,]    2013-01-24  460.0 465.73 450.25  450.5 52173300  450.5   -0.123558    2.33396    -1.39201
[3,]    2013-01-25 451.69 456.23  435.0 439.88 43143800 439.88  -0.0235738    2.27893    -1.68528
[4,]    2013-01-28 437.83 453.21 435.86 449.83 28054200 449.83   0.0226198    2.33048    -1.50955
[5,]    2013-01-29  458.5  460.2 452.12 458.27 20374400 458.27   0.0187626    2.37421    -1.27737
[6,]    2013-01-30  457.0  462.6  454.5 456.83 14887300 456.83 -0.00314225    2.36675    -1.09446

````

If you're interested in running the test suite, you can call the `@thyme` macro inside a Julia session.

````julia
julia> @thyme

Running tests: 
**   test/returns.jl
**   test/lag.jl
**   test/moving.jl
**   test/upto.jl
**   test/indexdate.jl
**   test/read.jl
````
