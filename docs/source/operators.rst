Mathematical, comparison, and logical operators
===============================================

TimeSeries supports common mathematical (such as ``+``), comparison ( such as ``==``)
, and logic (such as ``&``) operators. The operations are only calculated on values that share a timestamp.

mathematical
------------

Mathematical operators create a TimeArray object where values are computed on shared timestamps when two TimeArray 
objects are provided. Operations between a single TimeArray and ``Int`` or ``Float`` is also supported. The number 
can precede the TimeArray object or vice versa (e.g. ``cl + 2`` or ``2 + cl``).

Except in the case of the ``/`` operator, both dot (``.+``) and non-dot (``+``) operations are supported. The semantics
of non-dot operations are fairly clear when working with time series data, where it is assumed that only equivalent 
timestamped values are being operated on. 

The exclusion of ``/`` from this logic is a special case. In matrix operations it has been confused with being 
equivalent to the inverse, and because of the confusion base has excluded it. It is likewise excluded here. 

+------------------+------------------------------------------+
| Operator         | Description                              |
+==================+==========================================+
| ``+`` or  ``.+`` | mathematical element-wise addition       |
+------------------+------------------------------------------+
| ``-`` or  ``.-`` | mathematical element-wise subtraction    |
+------------------+------------------------------------------+
| ``*`` or  ``.*`` | mathematical element-wise multiplication |
+------------------+------------------------------------------+
|      ``./``      | mathematical element-wise division       |
+------------------+------------------------------------------+
| ``^`` or ``.^``  | mathematical element-wise exponentiation |
+------------------+------------------------------------------+
| ``%`` or ``.%``  | mathematical element-wise remainder      |
+------------------+------------------------------------------+

comparison
----------

Comparison operators create a TimeArray of type ``Bool``. Values are compared on shared timestamps when two TimeArray 
objects are provided. Comparison between a single TimeArray and ``Int``, ``Float``, or ``Bool`` is also supported. The semantics of
an non-dot operators (``>``) is unclear, so it is not supported.

+---------+-----------------------------------------------+
| Operator| Description                                   |
+=========+===============================================+
| ``.>``  | element-wise greater-than comparision         |
+---------+-----------------------------------------------+
| ``.<``  | element-wise less-than comparision            |
+---------+-----------------------------------------------+
| ``.==`` | element-wise equivalent comparison            |
+---------+-----------------------------------------------+
| ``.>=`` | element-wise greater-than or equal comparison |
+---------+-----------------------------------------------+
| ``.<=`` | element-wise less-than or equal comparison    |
+---------+-----------------------------------------------+
| ``.!=`` | element-wise not-equivalent comparison        |
+---------+-----------------------------------------------+

logic
-----

Logical operators are defined for TimeArrays of type ``Bool`` and return a TimeArray of type ``Bool``. Values are computed on shared timestamps when two TimeArray 
objects are provided. Operations between a single TimeArray and ``Bool`` are also supported.

+---------+---------------------------------+
| Operator| Description                     |
+=========+=================================+
| ``&``   | element-wise logical AND        |
+---------+---------------------------------+
| ``|``   | element-wise logical OR         |
+---------+---------------------------------+
| ``!``   | element-wise logical NOT        |
+---------+---------------------------------+
| ``$``   | element-wise logical XOR        |
+---------+---------------------------------+

