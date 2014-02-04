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

ja> ohlc[[firstday, tenthday]]
2x4 Array{Float64,2} 1980-01-03 to 1980-01-16

             Open       High    Low     Close
1980-01-03 | 105.76     106.08  103.26  105.22
1980-01-16 | 111.14     112.9   110.38  111.05
```
