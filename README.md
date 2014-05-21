TimeSeries.jl
============
[![Build Status](https://travis-ci.org/JuliaStats/TimeSeries.jl.png)](https://travis-ci.org/JuliaStats/TimeSeries.jl)
[![Package Evaluator](http://iainnz.github.io/packages.julialang.org/badges/TimeSeries_0.3.svg)](http://iainnz.github.io/packages.julialang.org/?pkg=TimeSeries&ver=0.3)

#### Installation

````julia
julia> Pkg.add("TimeSeries")
````
Additionally, the MarketData package includes some `const` objects that include TimeArray objects. These
objects are historical price time series and can be used for testing, benchmarking or simply taking TimeSeries
functionality through some paces. 

````julia
julia> Pkg.add("MarketData")
````

Alternately, you can create some dummy data with this code block.

````julia
d = [date(1980,1,1):date(2015,1,1)];
t = TimeArray(d,rand(length(d)),["test"])
````

#### Package objectives

TimeSeries aims to provide a lightweight framework for working with time series data in Julia. There are less than 500 total lines of code 
in the `src/` directory.

#### Quick tour of current API

````julia
julia> using TimeSeries, MarketData

julia> ohlc
500x4 TimeArray{Float64,2} 2000-01-03 to 2001-12-31

             Open    High    Low     Close
2000-01-03 | 104.88  112.5   101.69  111.94
2000-01-04 | 108.25  110.62  101.19  102.5
2000-01-05 | 103.75  110.56  103.0   104.0
2000-01-06 | 106.12  107.0   95.0    95.0
⋮
2001-12-26 | 21.35   22.3    21.14   21.49
2001-12-27 | 21.58   22.25   21.58   22.07
2001-12-28 | 21.97   23.0    21.96   22.43
2001-12-31 | 22.51   22.66   21.83   21.9
````

###### Split

````julia
julia> ohlc[1]
1x4 TimeArray{Float64,2} 2000-01-03 to 2000-01-03

             Open    High    Low     Close
2000-01-03 | 104.88  112.5   101.69  111.94

julia> ohlc[1:2]
2x4 TimeArray{Float64,2} 2000-01-03 to 2000-01-04

             Open    High    Low     Close
2000-01-03 | 104.88  112.5   101.69  111.94
2000-01-04 | 108.25  110.62  101.19  102.5

julia> ohlc[[date(2000,1,3), date(2000,1,14)]]
2x4 TimeArray{Float64,2} 2000-01-03 to 2000-01-14

             Open    High    Low     Close
2000-01-03 | 104.88  112.5   101.69  111.94
2000-01-14 | 100.0   102.25  99.38   100.44

julia> ohlc["Low"][1:2]
2x1 TimeArray{Float64,1} 2000-01-03 to 2000-01-04

             Low
2000-01-03 | 101.69
2000-01-04 | 101.19

julia> ohlc["Open", "Close"][1:2]
2x2 TimeArray{Float64,2} 2000-01-03 to 2000-01-04

             Open    Close
2000-01-03 | 104.88  111.94
2000-01-04 | 108.25  102.5
````

###### Apply

````julia
julia> op[1:3] .- cl[2:4]
2x1 TimeArray{Float64,1} 2000-01-04 to 2000-01-05

             Op.-Cl
2000-01-04 | 5.75
2000-01-05 | -0.25

julia> 2.*cl
500x1 TimeArray{Float64,1} 2000-01-03 to 2001-12-31

             Close
2000-01-03 | 223.88
2000-01-04 | 205.0
2000-01-05 | 208.0
2000-01-06 | 190.0
⋮
2001-12-26 | 42.98
2001-12-27 | 44.14
2001-12-28 | 44.86
2001-12-31 | 43.8

julia> percentchange(cl, method="log")
499x1 TimeArray{Float64,1} 2000-01-04 to 2001-12-31

             Close
2000-01-04 | -0.09
2000-01-05 | 0.01
2000-01-06 | -0.09
2000-01-07 | 0.05
⋮
2001-12-26 | 0.01
2001-12-27 | 0.03
2001-12-28 | 0.02
2001-12-31 | -0.02

julia> basecall(cl, cumsum)
500x1 TimeArray{Float64,1} 2000-01-03 to 2001-12-31

             Close
2000-01-03 | 111.94
2000-01-04 | 214.44
2000-01-05 | 318.44
2000-01-06 | 413.44
⋮
2001-12-26 | 23028.84
2001-12-27 | 23050.91
2001-12-28 | 23073.34
2001-12-31 | 23095.24i
````

###### Combine

````julia
julia> merge(op,cl)
500x2 TimeArray{Float64,2} 2000-01-03 to 2001-12-31

             Open    Close
2000-01-03 | 104.88  111.94
2000-01-04 | 108.25  102.5
2000-01-05 | 103.75  104.0
2000-01-06 | 106.12  95.0
⋮
2001-12-26 | 21.35   21.49
2001-12-27 | 21.58   22.07
2001-12-28 | 21.97   22.43
2001-12-31 | 22.51   21.9

julia> collapse(cl, last)
105x1 TimeArray{Float64,1} 2000-01-07 to 2001-12-31

             Close
2000-01-07 | 99.5
2000-01-14 | 100.44
2000-01-21 | 111.31
2000-01-28 | 101.62
⋮
2001-12-14 | 20.39
2001-12-21 | 21.0
2001-12-28 | 22.43
2001-12-31 | 21.9
````
