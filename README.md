TimeArrays.jl
============

temporary repo to explore combining Arrays of SeriesPair into multicolumn type with similar behavior

API in progress (check back often)
=========

```
julia> using TimeArrays, MarketData

julia> ohlc = TimeArray(op, hi, lo, cl);

julia> ohlc.colnames = ["Open", "High", "Low", "Close"];

julia> ohlc[1]
1x4 Array{Float64,2} 1980-01-03 to 1980-01-03

             Open       High    Low     Close
1980-01-03 | 105.76     106.08  103.26  105.22


julia> ohlc[1:2]
2x4 Array{Float64,2} 1980-01-03 to 1980-01-04

             Open       High    Low     Close
1980-01-03 | 105.76     106.08  103.26  105.22
1980-01-04 | 105.22     107.08  105.09  106.52

julia> ohlc[[firstday, tenthday]]
2x4 Array{Float64,2} 1980-01-03 to 1980-01-16

             Open       High    Low     Close
1980-01-03 | 105.76     106.08  103.26  105.22
1980-01-16 | 111.14     112.9   110.38  111.05

julia> ohlc["Low"][date(1980,1,1):days(1):date(1980,1,31)]
21x1 Array{Float64,2} 1980-01-03 to 1980-01-31

             Low
1980-01-03 | 103.26
1980-01-04 | 105.09
1980-01-07 | 105.8
1980-01-08 | 106.29
...
1980-01-25 | 112.36
1980-01-28 | 112.93
1980-01-29 | 113.03
1980-01-30 | 113.37
1980-01-31 | 113.78
```
