The TimeArray time series type
==============================

The TimeArray time series type is defined here (with inner constructor code removed for readability)::


    immutable TimeArray{T,N,D<:TimeType,A<:AbstractArray} <: AbstractTimeSeries

        timestamp::Vector{D}
        values::A # some kind of AbstractArray{T,N}
        colnames::Vector{UTF8String}
        meta::Any

        # inner constructor code enforcing invariants

    end

There are four fields for the type.

timestamp
---------

The ``timestamp`` field consists of a vector of values of a child type of of ``TimeType`` - in practise either ``Date`` or ``DateTime``.
The ``DateTime`` type is similar to the ``Date`` type except it represents time frames smaller than a day. For the construction
of a TimeArray to work, this vector needs to be sorted. If the vector includes dates that are not sequential, the construction
of the object will error out. The vector also needs to be ordered from oldest to latest date, but this can be handled by the
constructor and will not prohibit an object from being created.

values
------

The ``values`` field holds the data from the time series and its row count must match the length of the ``timestamp`` array. If these
do not match, the constructor will fail. All the values inside the ``values`` array must be of the same type.

colnames
--------

The ``colnames`` field is a vector of type ``UTF8String`` and contains the names of the columns for each column in the ``values``
field. The length of this vector must match the column count of the ``values`` array, or the constructor will fail. Since TimeArrays are 
indexable on column names, duplicate names in the ``colnames`` vector will be modified by the inner constructor. Each subsequent duplicate
name will be appended by ``_n`` where ``n`` enumerates from 1.

meta
----

The ``meta`` field defaults to holding nothing, which is represented by type ``Void``. This default is designed to allow programmers
to ignore this field. For those who wish to utilize this field, ``meta`` can hold common types such as ``String`` or more elaborate
user-defined types. One might want to assign a name to an object that is immutable versus relying on variable bindings outside of
the object's type fields.
