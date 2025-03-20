### 0.11.0

* `TimeArray` constructor, `merge`, `update`, `vcat` and `rename`
  will throw typed exceptions. (issue 322)

* Signature of `moving` becomes

  ```julia
    moving(f, ta::TimeArray, window; padding=false)
  ```

  , in order to support do-syntax. The original one is deprecated. (issue #TBD)

* Signature of `upto` becomes

  ```julia
    moving(f, ta::TimeArray, window; padding=false)
  ```

  , in order to support do-syntax. The original one is deprecated. (issue #TBD)

### 0.10.0

* add support for time series plotting via RecipesBase dependency (thank you @mkborregaard) 
* add StepRange indexing support (issue #311)

### 0.9.2

* improve readtimearray to accept IOBuffer (@femtotrader fixes issue #298)

### 0.9.1

* improve update method and dis-allow updating of empty time arrays (fixes issue #286)

### 0.9.0

* first version to support julia 0.5 release candidates

### 0.8.8

* merge method deals with meta field values more robustly (fixes issue #164)

### 0.8.7

* reexport Base.Dates methods and DataTypes (fixes issue #277)

### 0.8.6

* unique column names are enforced (fixes issue #255)

### 0.8.5

* update() method creates new TimeArray from existing one, with new timestamp/value pair.
* rename() method creates new TimeArray from existing one, with new column name(s).
* adds tail() and head() methods

### 0.8.4

* allows users to show customizable representations for missing values, which are represented as NaN values in the array.

### 0.8.3

* provides TimeArray constructor without requiring colnames argument (defaults to empty array)

### 0.8.2

* makes to() and from() more robust by taking zero-length time arrays (@dourouc05 )

### 0.8.1

* removes using Base.Dates from outside module @tkelman

### 0.8.0

* deprecated `collapse(ta::TimeArray, f::Function; period::Function=week)` in favour of `collapse(ta::TimeArray, period::Function, timestamp::Function, value::Function=timestamp)` and added support for collapsing 2D TimeArrays

### 0.7.4

* allow math operations between different Number subtypes
* explicitly convert column names to strings  in `readtimearray`
* operations between TimeArrays with non-matching meta fields now succeed, with a `Void` meta in the result

### 0.7.3

* ensure dates are sorted for vcat and map (@dourouc05)

### 0.7.2

* map and vcat methods added (thanks again @dourouc05)

### 0.7.1

* readtimearray method now allows arbitrary delimiters (thanks @dourouc05) 

### 0.7.0

* TimeType replaces Union{Date, DateTime}
* meta field in Type downgraded from parameterized to Any
* NaN sentinels added as a kwarg to lag and lead methods
* merge method now supports left, right and outer joins
* percentchange takes method argument as a Symbol vs String
* new methods added including: uniformspaced, uniformspace, dropnan, diff
* findall added to deprecated list in favor of find

### 0.6.7

* refactors when() method for 30% performance improvement

### 0.6.6

* begin deprecation of by() method, which is being replaced by when()
* when() re-arranges the argument order to TimeArray, Function, Int (or ASCIIString)
* support for ASCIIStrings are now provided for both by() and when() methods

### 0.6.5

* support added for displaying empty TimeArray
* common scalar -> scalar math functions as unary operators
* adds isnan and isinf
* fixes tests on meta field
* downgrades show tests to pending

### 0.6.4

* replaces Nothing -> nothing and String -> AbstractString

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
