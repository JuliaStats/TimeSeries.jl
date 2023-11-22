Combine methods
===============

TimeSeries supports merging two TimeArrays, and squishing the timestamp to a longer-term interval while representing values
that make sense.

merge
-----

The ``merge`` method performs joins between two TimeArrays. The default behaviour is to perform an inner join, such that the resulting
TimeArray contains only timestamps that both TimeArrays share, and values that correspond to that timestamp.

The AAPL object from MarketData has 8,336 rows of data from Dec 12, 1980 to Dec 31, 2013. If we merge it with the CAT object, which
contains 13,090 rows of data from Jan 2, 1962 to Dec 31, 2013 we might expect the resulting TimeArray to have 8,336 rows of
data, corresponding to the length of AAPL. This assumes that every day that Apple Computer, Inc. traded, Caterpillar, Inc likewise
traded. It turns out that this isn't true. CAT did not trade on Sep 27, 1985 because Hurricane Glorio shut down the New York
Stock Exchage. Apple Computer trades on the electronic NASDAQ and its trading was not halted on that day. The result of the merge
should then be 8,335 rows::

    julia> AppleCat= merge(AAPL,CAT);

    julia> length(AppleCat)
    8335

Left, right, and outer joins can also be performed by passing the corresponding symbol. These joins introduce ``NaN`` values when data
for a particular timestamp only exists in one of the series to be merged. For example::

    julia> merge(op[1:3], cl[2:4], :left)
    3x2 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2000-01-05

                 Open      Close
    2000-01-03 | 104.88    NaN
    2000-01-04 | 108.25    102.5
    2000-01-05 | 103.75    104.0


    julia> merge(op[1:3], cl[2:4], :right)
    3x2 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-04 to 2000-01-06

                 Open      Close
    2000-01-04 | 108.25    102.5
    2000-01-05 | 103.75    104.0
    2000-01-06 | NaN       95.0


    julia> merge(op[1:3], cl[2:4], :outer)
    4x2 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2000-01-06

                 Open      Close
    2000-01-03 | 104.88    NaN
    2000-01-04 | 108.25    102.5
    2000-01-05 | 103.75    104.0
    2000-01-06 | NaN       95.0

The ``merge`` method allows users to specify the value for the ``meta`` field of the merged object. When that value is not explicity
provided, ``merge`` will concatenate the ``meta`` field values, assuming these values to be strings. This covers the vast majority of 
use cases. In edge cases when users do not provide a ``meta`` value and both field values are not strings, the merged object will take
on ``Void`` as its ``meta`` field value.::
    
    julia> AppleCat.meta
    "AAPL_CAT"

    julia> CatApple = merge(CAT, AAPL, meta=47);

    julia> CatApple.meta
    47

    julia> merge(AppleCat, CatApple).meta
    Void

collapse
--------

The ``collapse`` method allows for compressing data into a larger time frame. For example, converting daily data into monthly data.
When compressing dates, something rational has to be done with the values that lived in the more granular time frame. To define what
happens, a function call is made. In our example, we want to compress the daily ``cl`` closing prices from daily to monthly. It makes
sense for us to take the ``last`` value known and have that represented with the corresponding timestamp. A non-exhaustive list of valid time methods is presented below.

+--------------+-------------+
| Dates method | Time length |
+==============+=============+
| ``day``      | daily       |
+--------------+-------------+
| ``week``     | weekly      |
+--------------+-------------+
| ``month``    | monthly     |
+--------------+-------------+
| ``year``     | yearly      |
+--------------+-------------+

Showing this code in REPL::

    julia> collapse(cl,month,last)
    24x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-31 to 2001-12-31

                 Close
    2000-01-31 | 103.75
    2000-02-29 | 114.62
    2000-03-31 | 135.81
    2000-04-28 | 124.06
    ⋮
    2001-09-28 | 15.51
    2001-10-31 | 17.56
    2001-11-30 | 21.3
    2001-12-31 | 21.9

We can also supply the function that chooses the timestamp and the function that determines the corresponding value independently::

    julia> collapse(cl, month, last, mean)
    24x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-31 to 2001-12-31

		Close     
    2000-01-31 | 103.3595  
    2000-02-29 | 111.6375  
    2000-03-31 | 128.5026  
    2000-04-28 | 123.1058  
    ⋮
    2001-09-28 | 16.602    
    2001-10-31 | 17.3222   
    2001-11-30 | 19.649    
    2001-12-31 | 21.695    


vcat
----

The ``vcat`` method is used to concatenate time series: if you have two time series with the same columns, but two distinct 
periods of time, this function can merge them into a single object. Notably, it can be used to merge data that is split into multiple
files. Its behaviour is quite different from ``merge``, which does not consider that its arguments are actually the *same* time series. 

This concatenation is *vertical* (``vcat``) because it does not create columns, it extends existing ones (which are represented vertically). 

For example::

    julia> a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
    2x1 TimeSeries.TimeArray{Int64,1,Date,Array{Int64,1}} 2015-10-01 to 2015-11-01
    
                 Number
    2015-10-01 | 15
    2015-11-01 | 16
    
    
    julia> b = TimeArray([Date(2015, 12, 01)], [17], ["Number"])
    1x1 TimeSeries.TimeArray{Int64,1,Date,Array{Int64,1}} 2015-12-01 to 2015-12-01
    
                 Number
    2015-12-01 | 17
    
    
    julia> vcat(a,b)
    3x1 TimeSeries.TimeArray{Int64,1,Date,Array{Int64,1}} 2015-10-01 to 2015-12-01
    
                 Number
    2015-10-01 | 15
    2015-11-01 | 16
    2015-12-01 | 17

map
---

This function allows complete transformation of the data within the time series, with alteration on both the time stamps and the associated values. 
It works exactly like ``Base.map``: the first argument is a binary function (the time stamp and the values) that returns two values, respectively 
the new time stamp and the new vector of values. It does not perform any kind of compression like ``collapse``, but rather transformations. 

The simplest example is to postpone all time stamps in the given time series, here by one year:: 

    julia> a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
    2x1 TimeSeries.TimeArray{Int64,1,Date,Array{Int64,1}} 2015-10-01 to 2015-11-01
    
                 Number
    2015-10-01 | 15
    2015-11-01 | 16
    
    
    julia> map((timestamp, values) -> (timestamp + Dates.Year(1), values), a)
    2x1 TimeSeries.TimeArray{Int64,1,Date,Array{Int64,1}} 2016-10-01 to 2016-11-01
    
                 Number
    2016-10-01 | 15
    2016-11-01 | 16
