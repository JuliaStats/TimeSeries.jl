Read method
===========

Reading a ``csv`` file into a TimeArray object is supported.

readtimearray
-------------

The ``readtimearray`` method is a wrapper for the ``Base.readcsv`` method that returns a TimeArray.

    function readtimearray(fname::String; delim=',', meta=Nothing, format::String="")

The ``fname`` argument is a string that represents the location and name of the ``csv`` file that you wish to parse into
a TimeArray object. Optionally, you can add a value to the ``meta`` field.

More generally, this function accepts arbitrary delimiters with ``delim``, just like ``Base.readcsv``.

For datetime data that has odd formatting, a ``format`` argument is provided where users can pass the format of their data.

For example::

    tm = readtimearray("close.csv", format="dd/mm/yyyy HH:MM", delim=';')

A more robust regex parsing engine is planned so users will not need to pass a time format for anything but the most edge cases.

writetimearray
-------------

The ``writetimearray`` method writes a TimeArray to the specified file as comma-seperated values. For example::

    julia> writetimearray(cl[1:5], "close.csv")

    shell> cat close.csv
    Timestamp,Close
    2000-01-03,111.94
    2000-01-04,102.5
    2000-01-05,104.0
    2000-01-06,95.0
    2000-01-07,99.5

