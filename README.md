Infrastructure code for getting data into a Julian data structure and
making basic transformations of that data. 

So far, there are handful of functions. The bang `!` version modifies a `DataFrame` with a new column. 

* `moving` and `moving!` 
* `lag` and `lag!` 
* `lead` and `lead!` 
* `simple_return` and `simple_return!` 
* `log_return` and `log_return!` 
* `equity` and `equity!` (works on prices) 
* `read_stock` that converts a csv file into a time series `DataFrame`    
 

#### TODO

* `upto` and `upto!` functions.
* `ema` function. (exponential moving average)

#### Demonstration


````julia

julia> using Thyme

julia> spx = read_stock("spx.csv");

julia> head(spx, 3)
3x7 DataFrame:
              Date  Open  High   Low Close   Volume Adj Close
[1,]    1970-01-02 92.06 93.54 91.79  93.0  8050000      93.0
[2,]    1970-01-05  93.0 94.25 92.53 93.46 11490000     93.46
[3,]    1970-01-06 93.46 93.81 92.13 92.82 11460000     92.82

julia> lead_closed = lead(spx["Close"], 1);

julia> tail(lead_closed)
7-element Float64 DataArray
 100.74
 100.95
 101.95
 102.21
 101.78
 102.09
 NA

julia> lagged_close = lag(spx["Close"],1);

julia> head(lagged_close)
6-element Float64 DataArray
 NA
 93.0
 93.46
 92.82
 92.63
 92.68
````

And to add a simple moving average ... 

````julia
julia> moving!(spx, "Adj Close", mean, 2);

julia> head(spx)
6x8 DataFrame:
              Date  Open  High   Low Close   Volume Adj Close mean_2
[1,]    1970-01-02 92.06 93.54 91.79  93.0  8050000      93.0     NA
[2,]    1970-01-05  93.0 94.25 92.53 93.46 11490000     93.46  93.23
[3,]    1970-01-06 93.46 93.81 92.13 92.82 11460000     92.82  93.14
[4,]    1970-01-07 92.82 93.38 91.93 92.63 10010000     92.63 92.725
[5,]    1970-01-08 92.63 93.47 91.99 92.68 10670000     92.68 92.655
[6,]    1970-01-09 92.68 93.25 91.82  92.4  9380000      92.4  92.54

````




