The TimeArray time series type
==============================

The TimeArray time series type is defined here (with inner constructor code removed for readability)::


    immutable TimeArray{T,N,M} <: AbstractTimeSeries

        timestamp::Union(Vector{Date}, Vector{DateTime})
        values::Array{T,N}
        colnames::Vector{UTF8String}
        meta::M

        # inner constructor code enforcing invariants

    end

There are four fields for the type. 

timestamp
---------

The ``timestamp`` field consists of a vector of either ``Date`` or ``DateTime`` type. The ``DateTime`` type is similar to the
``Date`` type except it represents time frames smaller than a day. For the construction of a TimeArray to work, this vector needs 
to be sorted. If the vector includes dates that are not sequential, the construction of the object will error out. The vector also
needs to be ordered from oldest to latest date, but this can be handled by the constructor and will not prohibit an object from 
being created. 

values
------

The ``values`` field holds the data from the time series and its length must match the length of the ``timestamp`` array. If these
do not match, the constructor will fail. All the values inside the ``values`` array must be of the same type.

colnames
--------

The ``colnames`` field is a vector of type ``UTF8String`` and contains the names of the columns for each column in the ``values``
field. The length of this vector must match the width of the ``values`` array, or the construction of an object will fail. 

meta
----

The ``meta`` field defaults to holding nothing, which is represented by type ``Void``. This default is designed to allow programmers
to ignore this field. For those that wish to utilize this field, ``meta`` can hold common types such as ``String`` or more elaborate 
user-defined types. One might want to assign a name to an object that is immutable versus relying on variable bindings outside of
the object's type fields.
