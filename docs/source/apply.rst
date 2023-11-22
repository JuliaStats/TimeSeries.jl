Apply methods
=============

Common transformation of time series data involves lagging, leading, calculating change, windowing operations and aggregation
operations. Each of these methods include keyword arguments that include defaults.

lag
---

The ``lag`` method simply described is putting yesterday's value in today's timestamp. This is the most common use case, though
there are many times the distance between timestamps is not 1 time unit. An arbitrary integer distance for lagging is supported,
with the default equal to 1.

The value of the ``cl`` object on Jan 3, 2000 is 111.94. On Jan 4, 2000 it is 102.50 and on Jan 5, 2000 it's 104.0::

    julia> cl[1:3]
    3x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-05

                Close
    2000-01-03 | 111.94
    2000-01-04 | 102.5
    2000-01-05 | 104.0

The ``lag`` method **moves** values up one day::

    julia> lag(cl[1:3])
    2x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2000-01-05

                 Close
    2000-01-04 | 111.94
    2000-01-05 | 102.5

You will notice that since there is no known value for lagging the first day, the observation on that timestamp is
omitted. This behavior is common in TimeSeries. When observations are consumed in a transformation, the artifact dates
are not preserved with a missingness value. To pad the returned TimeArray with ``NaN`` values instead, you can pass
``padding=true`` as a keyword argument::

    julia> lag(cl[1:3], padding=true)
    3x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-05

                 Close
    2000-01-03 | NaN
    2000-01-04 | 111.94
    2000-01-05 | 102.5

lead
----

Leading values operates similarly to lagging values, but moves things in the other direction. Arbitrary time distances is also
supported::

    julia> lead(cl[1:3])
    2x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-04

                 Close
    2000-01-03 | 102.5
    2000-01-04 | 104.0

Since we are leading an object of length 3, only two values will be transformed because we have lost a day to the transformation.

The ``cl`` object is 500 rows long so if we lead by 499 days, we should put the last observation in the object (which happens
to be on Dec 31, 2001) into the first date's value slot::

    julia> lead(cl, 499)
    1x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-03

                 Close
    2000-01-03 | 21.9

percentchange
------------

Calculating change between timestamps is a very common time series operation. We use the terms percent change, returns and
rate of change interchangably. Depending on which domain you're using time series, you may prefer one name over the other.

This package names the function that performs this transformation ``percentchange``. You're welcome to change this of course
if that represents too many letters for you to type::

    julia> roc = percentchange

The ``percentchange`` method includes the option to return a simple return or a log return. The default is set to ``simple``::

    julia> percentchange(cl)
    499x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2001-12-31

                 Close
    2000-01-04 | -0.0843
    2000-01-05 | 0.0146
    2000-01-06 | -0.0865
    2000-01-07 | 0.0474
    ⋮
    2001-12-26 | 0.0061
    2001-12-27 | 0.027
    2001-12-28 | 0.0163
    2001-12-31 | -0.0236

Log returns are popular for downstream calculations since adding returns is simpler than multiplying them. To create log
returns, pass the symbol ``:log`` to the method::

    julia> percentchange(cl, :log)
    499x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2001-12-31

                 Close
    2000-01-04 | -0.0881
    2000-01-05 | 0.0145
    2000-01-06 | -0.0905
    2000-01-07 | 0.0463
    ⋮
    2001-12-26 | 0.0061
    2001-12-27 | 0.0266
    2001-12-28 | 0.0162
    2001-12-31 | -0.0239

moving
------

Function signature::

    moving(f, ta::TimeArray, window; padding=false)
    moving(ta, window; padding=false) do x
        ...
    end

Often when working with time series, you want to take a sliding window view of the data and perform a calculation on it. The
simplest example of this is the moving average. For a 10-period moving average, you take the first ten values, sum then and
divide by 10 to get their average. Then you slide the window down one and to the same thing. This operation involves two important
arguments: the function that you want to use on your window and the size of the window you want to apply that function over.

In our moving average example, we would pass arguments this way::

    julia> moving(mean, cl, 10)
    491x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-14 to 2001-12-31

                 Close
    2000-01-14 | 98.782
    2000-01-18 | 97.982
    2000-01-19 | 98.388
    2000-01-20 | 99.338
    ⋮
    2001-12-26 | 21.065
    2001-12-27 | 21.123
    2001-12-28 | 21.266
    2001-12-31 | 21.417

As mentioned previously, we lose the first nine observations to the consuming nature of this operation. They are not **missing**
per se, they simply do not exist.

upto
----

Another operation common in time series analysis is an aggregation function. TimeSeries supports this with the ``upto`` method.
Suppose you want to keep track of the sum of all the values from the beginning to the present timestamp. You would use the
``upto`` method like this::

    julia> upto(sum, cl)
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

                 Close
    2000-01-03 | 111.94
    2000-01-04 | 214.44
    2000-01-05 | 318.44
    2000-01-06 | 413.44
    ⋮
    2001-12-26 | 23028.84
    2001-12-27 | 23050.91
    2001-12-28 | 23073.34
    2001-12-31 | 23095.24

basecall
-------
Because the algorithm for the ``upto`` method needs to be optimized further, it might be better to use a base method in its
place when one is available. Taking our summation example above, we could instead use the ``basecall`` method and realize
substantial performance improvements::

    julia> basecall(cl,cumsum)
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

                 Close
    2000-01-03 | 111.94
    2000-01-04 | 214.44
    2000-01-05 | 318.44
    2000-01-06 | 413.44
    ⋮
    2001-12-26 | 23028.84
    2001-12-27 | 23050.91
    2001-12-28 | 23073.34
    2001-12-31 | 23095.24
