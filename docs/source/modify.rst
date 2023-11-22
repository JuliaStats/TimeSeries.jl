Modify existing TimeArrays
==========================

Since TimeArrays are immutable, they cannot be altered or changed in-place. In practical application, an existing 
TimeArray might need to be used to create a new one with many of the same values. This might be thought of as *changing*
the fields of an existing TimeArray, but what actually happens is a new TimeArray is created. To allow the use of an 
existing TimeArray to create a new one, the ``update`` and ``rename`` methods are provided.

update
------

The ``update`` method supports adding new observations only. Older and in-between dates are not supported::

    julia> update(cl, Date(2002,1,1), 111.11)
    501x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2002-01-01

                 Close     
    2000-01-03 | 111.94    
    2000-01-04 | 102.5     
    2000-01-05 | 104.0     
    2000-01-06 | 95.0      
    ⋮
    2001-12-27 | 22.07     
    2001-12-28 | 22.43     
    2001-12-31 | 21.9      
    2002-01-01 | 111.11

    julia> update(cl, Date(2002,1,1), [111.11])
    501x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2002-01-01

                 Close     
    2000-01-03 | 111.94    
    2000-01-04 | 102.5     
    2000-01-05 | 104.0     
    2000-01-06 | 95.0      
    ⋮
    2001-12-27 | 22.07     
    2001-12-28 | 22.43     
    2001-12-31 | 21.9      
    2002-01-01 | 111.11

    julia> update(ohlc, Date(2002,1,1), [111.11, 222.22, 333.33, 444.44])
    501x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2002-01-01

                 Open      High      Low       Close     
    2000-01-03 | 104.88    112.5     101.69    111.94    
    2000-01-04 | 108.25    110.62    101.19    102.5     
    2000-01-05 | 103.75    110.56    103.0     104.0     
    2000-01-06 | 106.12    107.0     95.0      95.0      
    ⋮
    2001-12-27 | 21.58     22.25     21.58     22.07     
    2001-12-28 | 21.97     23.0      21.96     22.43     
    2001-12-31 | 22.51     22.66     21.83     21.9      
    2002-01-01 | 111.11    222.22    333.33    444.44

rename
------

The ``rename`` method allows the column name(s) to be changed::

    julia> rename(cl, "New Close")
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

                 New Close  
    2000-01-03 | 111.94     
    2000-01-04 | 102.5      
    2000-01-05 | 104.0      
    2000-01-06 | 95.0       
    ⋮
    2001-12-26 | 21.49      
    2001-12-27 | 22.07      
    2001-12-28 | 22.43      
    2001-12-31 | 21.9

    julia> rename(cl, ["New Close"])
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

                 New Close  
    2000-01-03 | 111.94     
    2000-01-04 | 102.5      
    2000-01-05 | 104.0      
    2000-01-06 | 95.0       
    ⋮
    2001-12-26 | 21.49      
    2001-12-27 | 22.07      
    2001-12-28 | 22.43      
    2001-12-31 | 21.9

    julia> rename(ohlc, ["New Open", "New High", "New Low", "New Close"])
    500x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31

                 New Open  New High  New Low   New Close  
    2000-01-03 | 104.88    112.5     101.69    111.94     
    2000-01-04 | 108.25    110.62    101.19    102.5      
    2000-01-05 | 103.75    110.56    103.0     104.0      
    2000-01-06 | 106.12    107.0     95.0      95.0       
    ⋮
    2001-12-26 | 21.35     22.3      21.14     21.49      
    2001-12-27 | 21.58     22.25     21.58     22.07      
    2001-12-28 | 21.97     23.0      21.96     22.43      
    2001-12-31 | 22.51     22.66     21.83     21.9
