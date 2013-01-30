A toolkit of Julia functions for comman time series transformations including:
lagging data, calculating moving values, calculating returns (both simple and log), 
and downloading financial time series from Yahoo.
 
#### Demonstration

````julia
julia> using Thyme

julia> AAPL = read_yahoo("AAPL");

julia> tail(AAPL, 3)
3x10 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj    Adj_RET Adj_equity skewness_30
[1,]    2013-01-25 451.69 456.23  435.0 439.88 43143800 439.88 -0.0235738    146.627    -1.68528
[2,]    2013-01-28 437.83 453.21 435.86 449.83 28054200 449.83  0.0226198    149.943    -1.50955
[3,]    2013-01-29  458.5  460.2 452.12 458.27 20374400 458.27  0.0187626    152.757    -1.27737
````

Include simple returns, an equity curve and a moving skewness over 30 periods.

````julia
julia> simple_return!(AAPL, "Adj");

julia> equity!(AAPL, "Adj");

julia> moving!(AAPL, "Adj", skewness, 30);

julia> tail(AAPL, 3)
3x10 DataFrame:
              Date   Open   High    Low  Close      Vol    Adj    Adj_RET Adj_equity skewness_30
[1,]    2013-01-25 451.69 456.23  435.0 439.88 43143800 439.88 -0.0235738    146.627    -1.68528
[2,]    2013-01-28 437.83 453.21 435.86 449.83 28054200 449.83  0.0226198    149.943    -1.50955
[3,]    2013-01-29  458.5  460.2 452.12 458.27 20374400 458.27  0.0187626    152.757    -1.27737
````

If you're interested in running the test suite, you can call the `@testthyme` macro inside a Julia session.

````julia
julia> @testthyme
Running tests: 
**   test/returns.jl
**   test/lag.jl
**   test/moving.jl
**   test/upto.jl
**   test/read.jl
````
