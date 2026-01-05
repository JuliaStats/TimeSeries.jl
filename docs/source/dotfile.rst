Customize how TimeArray is displayed
====================================

A dot file named ``.timeseriesrc`` sets three variables that control how TimeArrays are displayed. This doesn't change the 
underlying TimeArray and only controls how values are printed to REPL.

DECIMALS
--------

``DECIMALS = 4``

The default setting is 4. It shows values out to four decimal places::

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

You can change it to whatever value you prefer. If you change it to 6, the same transformation will display like this::

    julia> percentchange(cl)
    499x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2001-12-31

                 Close
    2000-01-04 | -0.084331
    2000-01-05 | 0.014634
    2000-01-06 | -0.086538
    2000-01-07 | 0.047368
    ⋮
    2001-12-26 | 0.006086
    2001-12-27 | 0.026989
    2001-12-28 | 0.016312
    2001-12-31 | -0.023629

SHOWINT
-------

``SHOWINT = true``

The default setting is ``true``. This will display floats as integers, which is a little trick to make things look nicer.

Here is an example in REPL::

    julia> ohlcv
    500x5 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31

                 Open      High      Low       Close     Volume
    2000-01-03 | 104.88    112.5     101.69    111.94    4783900
    2000-01-04 | 108.25    110.62    101.19    102.5     4574800
    2000-01-05 | 103.75    110.56    103.0     104.0     6949300
    2000-01-06 | 106.12    107.0     95.0      95.0      6856900
    ⋮
    2001-12-26 | 21.35     22.3      21.14     21.49     2614300
    2001-12-27 | 21.58     22.25     21.58     22.07     3419800
    2001-12-28 | 21.97     23.0      21.96     22.43     5341500
    2001-12-31 | 22.51     22.66     21.83     21.9      2460400

All the values in this object are of type ``Float`` but the Volume column makes them appear as ``Integer``. The
``show`` method inspects the column values to determine if any of them have values on the right side of the decimal.
If they don't, they display without a decimal. If you prefer to not use this form of trickery and decry the underlying
deception at play, you can assign this varaible to ``false``. The same object will then display this way::

    julia> ohlcv
    500x5 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31

                 Open      High      Low       Close     Volume
    2000-01-03 | 104.88    112.5     101.69    111.94    4.7839e6
    2000-01-04 | 108.25    110.62    101.19    102.5     4.5748e6
    2000-01-05 | 103.75    110.56    103.0     104.0     6.9493e6
    2000-01-06 | 106.12    107.0     95.0      95.0      6.8569e6
    ⋮
    2001-12-26 | 21.35     22.3      21.14     21.49     2.6143e6
    2001-12-27 | 21.58     22.25     21.58     22.07     3.4198e6
    2001-12-28 | 21.97     23.0      21.96     22.43     5.3415e6
    2001-12-31 | 22.51     22.66     21.83     21.9      2.4604e6

MISSING
-------

This output is controlled with ``const`` values to accomodate difficult to remember unicode numbers::

    const NAN       = "NaN"
    const NA        = "NA"
    const BLACKHOLE = "\u2B24"
    const DOTCIRCLE = "\u25CC"
    const QUESTION  = "\u003F"

    MISSING = NAN

The default setting displays ``NaN``, which represent the actual value when ``padding=true`` is selected for certain transformations. You
can change it to show differently with the provided ``const`` values or roll your own. Dot files are often used to customize your
experience, so have at it!

Here is an example in REPL with the default::

    julia> lag(cl, padding=true)
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

    Close     
    2000-01-03 | NaN       
    2000-01-04 | 111.94    
    2000-01-05 | 102.5     
    2000-01-06 | 104.0     
    ⋮
    2001-12-26 | 21.36     
    2001-12-27 | 21.49     
    2001-12-28 | 22.07     
    2001-12-31 | 22.43    

Here is an example in REPL with NA selected::

    julia> lag(cl, padding=true)
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
    
    Close     
    2000-01-03 | NA        
    2000-01-04 | 111.94    
    2000-01-05 | 102.5     
    2000-01-06 | 104.0     
    ⋮
    2001-12-26 | 21.36     
    2001-12-27 | 21.49     
    2001-12-28 | 22.07     
    2001-12-31 | 22.43     

Here is an example in REPL with BLACKHOLE selected::

    julia> lag(cl, padding=true)
    500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31

    Close     
    2000-01-03 | ⬤        
    2000-01-04 | 111.94    
    2000-01-05 | 102.5     
    2000-01-06 | 104.0     
    ⋮
    2001-12-26 | 21.36     
    2001-12-27 | 21.49     
    2001-12-28 | 22.07     
    2001-12-31 | 22.43   

Other ``Const`` values include DOTCIRCLE and QUESTION. The UNICORN value is a feature request.
