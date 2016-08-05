Updating existing TimeArrays
============================

Since TimeArrays are immutable, they cannot be altered or changed in-place. In practical application, an existing 
TimeArray might need to be used to create a new one with many of the same values. This might be thought of as *changing*
the fields of an existing TimeArray, but what actually happens is a new TimeArray is created. To allow the use of an 
existing TimeArray to create a new one, the ``update`` method is provided.

update
------

The ``update`` methods ::

    julia> when(cl, dayofweek, 1)
