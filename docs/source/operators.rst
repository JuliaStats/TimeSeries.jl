Mathematical and comparison operators
=====================================

TimeSeries supports common mathematical (such as ``+``) and comparison ( such as ``==``)
operators. The operations are only calculated on values that share a timestamp.

mathematical
------------

Mathematical operators create a TimeArray object where values are computed on shared timestamps when two TimeArray 
objects are provided. Operations between a single TimeArray and ``Int`` or ``Float`` is also supported.  The semantics 
of a single operator (``+``) and one preceded with a ``.`` is identical since operations are bound to shared timestamps
when two TimeArrays are calculated against one another. Support for the broadcasting ``.`` is provided for convenience.


+------------------+-----------------------------------------+
| Operator         | Description                             |
+==================+=========================================+
| ``+`` or  ``.+`` | mathematial element-wise add            |
+------------------+-----------------------------------------+
| ``-`` or  ``.-`` | mathematial element-wise subtraction    |
+------------------+-----------------------------------------+
| ``*`` or  ``.*`` | mathematial element-wise multiplication |
+------------------+-----------------------------------------+
| ``/`` or  ``./`` | mathematial element-wise division       |
+------------------+-----------------------------------------+

comparison
----------

Comparison operators create a TimeArray of type ``Bool``. Values are compared on shared timestamps when two TimeArray 
objects are provided. Comparison between a single TimeArray and ``Int`` or ``Float`` is also supported. The semantics of
an operator (``>``) and its broadcasting relative (``.>``) are identical. 

+-------------------+-----------------------------------------------+
| Operator          | Description                                   |
+===================+===============================================+
| ``>`` or ``.>``   | element-wise greater-than comparision         |
+-------------------+-----------------------------------------------+
| ``<`` or ``.<``   | element-wise less-than comparision            |
+-------------------+-----------------------------------------------+
| ``==`` or ``.==`` | element-wise equivalent comparison            |
+-------------------+-----------------------------------------------+
| ``>=`` or ``.>=`` | element-wise greater-than or equal comparison |
+-------------------+-----------------------------------------------+
| ``<=`` or ``.<=`` | element-wise less-than or equal comparison    |
+-------------------+-----------------------------------------------+
