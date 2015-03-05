Combine methods
===============

TimeSeries supports merging two TimeArrays, and squishing the timestamp to a longer-term interval while representing values
that make sense.

merge
-----

The ``merge`` method only performs inner joins on two TimeArrays. The resulting TimeArray contains only timestamps that both
TimeArrays share, and values that correspond to that timestamp.

The AAPL object from MarketData has 8,336 rows of data from Dec 12, 1980 to Dec 31, 2013. If we merge it with the CAT object, which
contains 13,090 rows of data from Jan 2, 1962 to Dec 31, 2013 we might expect the resulting TimeArray to have 8,336 rows of 
data, corresponding to the length of AAPL. This assumes that every day that Apple Computer, Inc. traded, Caterpillar, Inc likewise
traded. It turns out that this isn't true. CAT did not trade on Sep 27, 1985 because Hurricane Glorio shut down the New York
Stock Exchage. Apple Computer trades on the electronic NASDAQ and its trading was not halted on that day. The result of the merge
should then be 8,335 rows::

    julia> Caterapple = merge(AAPL,CAT);

    julia> length(Caterapple)
    8335

Currently, the ``merge`` method will not merge objects that have different values in the ``meta`` field. The APPL and CAT objects
have ``Void`` in their respective ``meta`` fields.

collapse
--------

The ``collapse`` method allows for compressing data into a larger time frame. For example, converting daily data into monthly data.
When compressing dates, something rational has to be done with the values that lived in the more granular time frame. To define what
happens, a function call is made. In our example, we want to compress the daily ``cl`` closing prices from daily to monthly. It makes
sense for us to take the last value known and have that represented with the derived timestamp. The ``collapse`` keyword argument for
time frame is the ``week`` method, which is defined in Dates.jl. A list of valid time methods is presented below.

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

    julia> collapse(cl,last,period=month)
    24x1 TimeSeries.TimeArray{Float64,1,DataType} 2000-01-31 to 2001-12-31

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
