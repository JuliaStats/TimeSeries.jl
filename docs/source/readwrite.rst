Read method
===========

Reading a ``csv`` file into a TimeArray object is supported.

readtimearray
-------------

The ``readtimearray`` method is a wrapper for the ``Base.readcsv`` method that returns a TimeArray.

    function readtimearray(fname::String; meta=Nothing)

The ``fname`` argument is a string that represents the location and name of the ``csv`` file that you wish to parse into
a TimeArray object. Optionally, you can add a value to the ``meta`` field.

This method is currently limited in its ability to parse different representations for a timestamp value. See 
`TimeSeries issue #105 <https://github.com/JuliaStats/TimeSeries.jl/issues/105>`_. If you're bored some weekend and feel like 
ruining some brain cells on regex, then feel free to fix this and submit a pull request. 
