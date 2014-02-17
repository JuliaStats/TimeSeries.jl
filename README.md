TimeSeries.jl
============
[![Build Status](https://travis-ci.org/JuliaStats/TimeSeries.jl.png)](https://travis-ci.org/JuliaStats/TimeSeries.jl)

#### Installation

````julia
julia> Pkg.add("TimeSeries")
````
Additionally, the unregistered MarketData package includes some `const` objects that include TimeArray objects. These
objects are historical price time series and are used in testing and benchmarking mostly. You may find it useful to 
clone the package and take TimeSeries functionality through some paces with these objects. 

````julia
julia> Pkg.clone("git://github.com/JuliaQuant/MarketData.jl.git")
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
505x6 TimeArray{Float64,2} 1980-01-03 to 1981-12-31

             Open    High    Low     Close   Volume       Adj Cl
1980-01-03 | 105.76  106.08  103.26  105.22  50480000.00  105.22
1980-01-04 | 105.22  107.08  105.09  106.52  39130000.00  106.52
1980-01-07 | 106.52  107.80  105.80  106.81  44500000.00  106.81
1980-01-08 | 106.81  109.29  106.29  108.95  53390000.00  108.95
...
1981-12-24 | 122.31  123.06  121.57  122.54  23940000.00  122.54
1981-12-28 | 122.54  123.36  121.73  122.27  28320000.00  122.27
1981-12-29 | 122.27  122.90  121.12  121.67  35300000.00  121.67
1981-12-30 | 121.67  123.11  121.04  122.30  42960000.00  122.30
1981-12-31 | 122.30  123.42  121.57  122.55  40780000.00  122.55
````

###### Split

````julia
julia> ohlc[1]
1x6 TimeArray{Float64,2} 1980-01-03 to 1980-01-03

             Open    High    Low     Close   Volume       Adj Cl
1980-01-03 | 105.76  106.08  103.26  105.22  50480000.00  105.22


julia> ohlc[1:2]
2x6 TimeArray{Float64,2} 1980-01-03 to 1980-01-04

             Open    High    Low     Close   Volume       Adj Cl
1980-01-03 | 105.76  106.08  103.26  105.22  50480000.00  105.22
1980-01-04 | 105.22  107.08  105.09  106.52  39130000.00  106.52

julia> ohlc[[firstday, tenthday]]
2x6 TimeArray{Float64,2} 1980-01-03 to 1980-01-16

             Open    High    Low     Close   Volume       Adj Cl
1980-01-03 | 105.76  106.08  103.26  105.22  50480000.00  105.22
1980-01-16 | 111.14  112.90  110.38  111.05  67700000.00  111.05


julia> ohlc["Low"][1:2]
2x1 TimeArray{Float64,2} 1980-01-03 to 1980-01-04

             Low
1980-01-03 | 103.26
1980-01-04 | 105.09

julia> ohlc["Open", "Close"][1:2]
2x2 TimeArray{Float64,2} 1980-01-03 to 1980-01-04

             Open    Close
1980-01-03 | 105.76  105.22
1980-01-04 | 105.22  106.52

````

###### Apply

````julia
julia> op[1:3] .- cl[2:4]
2x1 TimeArray{Float64,1} 1980-01-04 to 1980-01-07

            Op.-Cl
1980-01-04 | -1.30
1980-01-07 | -0.29

julia> 2cl
505x1 TimeArray{Float64,1} 1980-01-03 to 1981-12-31

             Close
1980-01-03 | 210.44
1980-01-04 | 213.04
1980-01-07 | 213.62
1980-01-08 | 217.90
...
1981-12-24 | 245.08
1981-12-28 | 244.54
1981-12-29 | 243.34
1981-12-30 | 244.60
1981-12-31 | 245.10

julia> percentchange(cl, method="log")
504x1 TimeArray{Float64,1} 1980-01-04 to 1981-12-31

            Close
1980-01-04 | 0.01
1980-01-07 | 0.00
1980-01-08 | 0.02
1980-01-09 | 0.00
...
1981-12-24 | 0.00
1981-12-28 | 0.00
1981-12-29 | 0.00
1981-12-30 | 0.01
1981-12-31 | 0.00

julia> basecall(cl, cumsum)
505x1 TimeArray{Float64,1} 1980-01-03 to 1981-12-31

             Close
1980-01-03 | 105.22
1980-01-04 | 211.74
1980-01-07 | 318.55
1980-01-08 | 427.50
...
1981-12-24 | 61832.70
1981-12-28 | 61954.97
1981-12-29 | 62076.64
1981-12-30 | 62198.94
1981-12-31 | 62321.49

````

###### Combine

````julia

julia> merge(op, cl)
505x2 TimeArray{Float64,2} 1980-01-03 to 1981-12-31

             Open    Close
1980-01-03 | 105.76  105.22
1980-01-04 | 105.22  106.52
1980-01-07 | 106.52  106.81
1980-01-08 | 106.81  108.95
...
1981-12-24 | 122.31  122.54
1981-12-28 | 122.54  122.27
1981-12-29 | 122.27  121.67
1981-12-30 | 121.67  122.30
1981-12-31 | 122.30  122.55

julia> collapse(cl, last)
105x1 TimeArray{Float64,1} 1980-01-04 to 1981-12-31

             Close
1980-01-04 | 106.52
1980-01-11 | 109.92
1980-01-18 | 111.07
1980-01-25 | 113.61
...
1981-12-04 | 126.26
1981-12-11 | 124.93
1981-12-18 | 124.00
1981-12-24 | 122.54
1981-12-31 | 122.55
````
