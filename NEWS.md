### 0.6.3

* precompile support added
* test/combine.jl and test/split.jl now imports Base.Dates explicity 

### 0.6.2

* added support for `end` keyword in indices
* added support for lookups via Boolean TimeArrays - e.g. ta[ta["col"] .> 50]
* speedup for lookups via lists of Date/DateTime objects

### 0.6.1

* a phantom release that is actually older than 0.6.0

### 0.6.0

* first version with support for Julia 0.4 only
* generalized value container from Array to AbstractArray
* implemented new element-wise operators: !, ~, &, |, $, %, !==
* implemented element-wise unary math operators (+, -)
* side note: a previous commit was tagged with v0.6.0 incorrectly, this commit resolves that mistake

### 0.5.11

* last version with support for Julia 0.3
* support for Julia 0.4 dropped, along with the Compat package

### 0.5.10

* changed references of flipud(A) to flipdim(A,1)_
* changed references of round(x) to iround(Integer,x)_
* changed references of iround(Integer,x) back to round(Integer,x)_
* changed references of int(x) to round(Int64, x)
* changed references of float(x) to map(Float64, x)
* changed references of [a] to [a;] in a comprehension found in the by() method
* added Compat package
* substantial speedup for element-wise mathematical operators

### 0.5.9

* added kwarg argument `format` to the `readtimearray` method to allow parsing datetime formats that are not 
currently supported.
* changed two references to `Range1` to `UnitRange`
* added import of Base.values. I had defined it first and I guess they like it so much they co-opted it. :)

### pre-0.5.8

Not currently documented.
