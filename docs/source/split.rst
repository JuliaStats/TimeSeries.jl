Splitting by time constraint or when condition is true
======================================================

Specific methods for segmenting on time ranges or if condition is met is supported with the following methods.

when
----

The ``when`` methods allows aggregating elements from a TimeArray into specific time periods,
such as Mondays or the month of October ::

    julia> when(cl, dayofweek, 1)
    95x1 TimeSeries.TimeArray{Float64,1,ASCIIString} 2000-01-03 to 2001-12-31

                 Close
    2000-01-03 | 111.94
    2000-01-10 | 97.75
    2000-01-24 | 106.25
    2000-01-31 | 103.75
    ⋮
    2001-12-10 | 22.54
    2001-12-17 | 20.62
    2001-12-24 | 21.36
    2001-12-31 | 21.9

    julia> when(cl, dayname, "Monday")
    95x1 TimeSeries.TimeArray{Float64,1,ASCIIString} 2000-01-03 to 2001-12-31

                 Close
    2000-01-03 | 111.94
    2000-01-10 | 97.75
    2000-01-24 | 106.25
    2000-01-31 | 103.75
    ⋮
    2001-12-10 | 22.54
    2001-12-17 | 20.62
    2001-12-24 | 21.36
    2001-12-31 | 21.9

by - being deprecated in favor of when
--------------------------------------

The ``by`` method allows aggregating elements from a TimeArray into specific time periods,
such as Mondays or the month of October - this method is being deprecated ::

    julia> by(cl, 1, period=dayofweek)
    95x1 TimeSeries.TimeArray{Float64,1,DataType} 2000-01-03 to 2001-12-31

                 Close
    2000-01-03 | 111.94
    2000-01-10 | 97.75
    2000-01-24 | 106.25
    2000-01-31 | 103.75
    ⋮
    2001-12-10 | 22.54
    2001-12-17 | 20.62
    2001-12-24 | 21.36
    2001-12-31 | 21.9

The period argument holds a valid ``Date`` method. Below are currently available alternatives.

+----------------------+--------------------------+
| Dates method         | Example                  |
+======================+==========================+
| ``day``              | Jan 3, 2000 = 3          |
+----------------------+--------------------------+
| ``dayname``          | Jan 3, 2000 = "Monday"   |
+----------------------+--------------------------+
| ``week``             | Jan 3, 2000 = 1          |
+----------------------+--------------------------+
| ``month``            | Jan 3, 2000 = 1          |
+----------------------+--------------------------+
| ``monthname``        | Jan 3, 2000 = "January"  |
+----------------------+--------------------------+
| ``year``             | Jan 3, 2000 = 2000       |
+----------------------+--------------------------+
| ``dayofweek``        | Monday = 1               |
+----------------------+--------------------------+
| ``dayofweekofmonth`` | Fourth Monday in Jan = 4 |
+----------------------+--------------------------+
| ``dayofyear``        | Dec 31, 2000 = 366       |
+----------------------+--------------------------+
| ``quarterofyear``    | Dec 31, 2000 = 4         |
+----------------------+--------------------------+
| ``dayofquarter``     | Dec 31, 2000 = 93        |
+----------------------+--------------------------+

from
----

The ``from`` method truncates a TimeArray starting with the date passed to the method::

    julia> from(cl, Date(2001, 12, 27))
    3x1 TimeSeries.TimeArray{Float64,1,DataType} 2001-12-27 to 2001-12-31

                 Close
    2001-12-27 | 22.07
    2001-12-28 | 22.43
    2001-12-31 | 21.9

to
--

The ``to`` method truncates a TimeArray after the date passed to the method::

    julia> to(cl, Date(2000, 1, 5))
    3x1 TimeSeries.TimeArray{Float64,1,DataType} 2000-01-03 to 2000-01-05

                 Close
    2000-01-03 | 111.94
    2000-01-04 | 102.5
    2000-01-05 | 104.0

findwhen
--------

The ``findwhen`` method test a condition and returns a vector of ``Date`` or ``DateTime`` where the condition is ``true``::

    julia> green = findwhen(ohlc["Close"] .> ohlc["Open"]);

    julia> typeof(green)
    Array{Date,1}

    julia> ohlc[green]
    244x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-28

                 Open      High      Low       Close
    2000-01-03 | 104.88    112.5     101.69    111.94
    2000-01-05 | 103.75    110.56    103.0     104.0
    2000-01-07 | 96.5      101.0     95.5      99.5
    2000-01-13 | 94.48     98.75     92.5      96.75
    ⋮
    2001-12-24 | 20.9      21.45     20.9      21.36
    2001-12-26 | 21.35     22.3      21.14     21.49
    2001-12-27 | 21.58     22.25     21.58     22.07
    2001-12-28 | 21.97     23.0      21.96     22.43

find
----

The ``find`` method tests a condition and returns a vector of ``Int`` representing the row in the array where the condition
is ``true``::

    julia> red = find(ohlc["Close"] .< ohlc["Open"]);

    julia> typeof(red)
    Array{Int64,1}

    julia> ohlc[red]
    252x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-04 to 2001-12-31

                 Open      High      Low       Close
    2000-01-04 | 108.25    110.62    101.19    102.5
    2000-01-06 | 106.12    107.0     95.0      95.0
    2000-01-10 | 102.0     102.25    94.75     97.75
    2000-01-11 | 95.94     99.38     90.5      92.75
    ⋮
    2001-12-14 | 20.73     20.83     20.09     20.39
    2001-12-20 | 21.4      21.47     20.62     20.67
    2001-12-21 | 21.01     21.54     20.8      21.0
    2001-12-31 | 22.51     22.66     21.83     21.9

Splitting by head and tail
==========================

head
----

The ``head`` method defaults to returning only the first value in a TimeArray. By selecting the second positional
argument to a different value, the user can modify how many from the top are selected::

    julia> head(cl)
    1x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-03

                 Close     
    2000-01-03 | 111.94    
    
    
    julia> head(cl,3)
    3x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-05
    
                 Close     
    2000-01-03 | 111.94    
    2000-01-04 | 102.5     
    2000-01-05 | 104.0   

tail
----

The ``tail`` method defaults to returning only the last value in a TimeArray. By selecting the second positional
argument to a different value, the user can modify how many from the bottom are selected::

    julia> tail(cl)
    1x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2001-12-31 to 2001-12-31
    
                 Close    
    2001-12-31 | 21.9     
    
    
    julia> tail(cl,3)
    3x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2001-12-27 to 2001-12-31
    
                 Close    
    2001-12-27 | 22.07    
    2001-12-28 | 22.43    
    2001-12-31 | 21.9     
