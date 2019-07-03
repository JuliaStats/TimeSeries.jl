### 0.16.0

* Improve performance of `moving` function. (#414)

* `moving` supports multi-column as input for user-defined function. (#415)

  ```julia
  moving(ohlc, 10, dims = 2, colnames = [:A, ...]) do
    # given that `ohlc` is a 500x4 `TimeArray`,
    # size(A) is (10, 4)
    ...
  end
  ```

* The argument `method` of function `merge` is a keyword argument now. (#416)

  ```julia
  merge(x, y, method = :outer)
  ```

* The function `merge` supports variable length input. (#416)

  ```julia
  merge(x, y, [zs...], method = :outer)
  ```

* New function `rename!` for in-place update of column names. (#417)

* Fix issues of `TimeArray` column names copying. (#418)

* Fix `@inbounds` handling for `TimeArray`. (#425)

* `timearray[]` throws `BoundsError` now. (#420)

  ```julia
  julia> cl[]
  ERROR: BoundsError: attempt to access TimeArray{Float64,1,Date,Array{Float64,1}}
    at index []
  ```

* `Tables.jl` interface integration. (#382)

* 2D `getindex` supports. (#423)

  ```julia
  ohlc[1:42,   [:High, :Low]]
  ohlc[42:end, [:High, :Low]]
  ohlc[:,      [:High, :Low]]
  ohlc[42,     [:High, :Low]]
  ```


### 0.15.0

* New `TimeArray` constructor for creating a `TimeArray` from existing `TimeArray`.
  ([#380])

  ```julia
      TimeArray(ta::TimeArray; timestamp = ..., values = ..., colnames = ..., meta = ...)
  ```

  E.g.
  ```julia
  julia> meta(cl)
  "AAPL"

  julia> cl′ = TimeArray(cl; meta = :AAPL);

  julia> meta(cl′)
  :AAPL
  ```

* `merge` now throws `ArgumentError` on invalid column setup. ([#405])

* `percentchange` and `dropnan` now throw `ArgumentError` on invalid `method`. ([#405])


### 0.14.0

* Symbol column indexing. ([#377])
  And the String indexing is deprecated.

  E.g.

  ```julia
  using MarketData
  ohlc[:Close]  # and cl["Close"] is deprecated
  ```

* `Base.getproperty` support. ([#377])
  All the columns can be accessed via the form `ta.column_name`.

  E.g.

  ```julia
  using MarketData
  ohlc.Open
  ```

  The original `TimeArray` fields getters is available as functions.

    * `timestamp(::TimeArray)`
    * `values(::TimeArray)`
    * `colnames(::TimeArray)`
    * `meta(::TimeArray)`

  ```julia
  ohlc.values  # this is unavailable due to Base.getproperty support
  values(ohlc)  # change to this
  ```

[#377]: https://github.com/JuliaStats/TimeSeries.jl/pull/377


### 0.13.0

* Julia v0.7/1.0 support. ([#370])

[#370]: https://github.com/JuliaStats/TimeSeries.jl/pull/370


### 0.12.0

* Support `Base.copy(::TimeArray)`. ([#352])

* A new option for `TimeArray` constructor: `unchecked::Bool` to skip
  the sanity check of timestamp. ([#361])

  * `merge()` optimization via the `unchecked` option. ([#363])

* Revoking deprecation warning of `==` and redefining its meaning as
  'comparing all fields of two `TimeArray`s'.
  Note that if two `TimeArray`s have different dimension, we consider that is
  unequal.
  ([#356], [#357])

  ```julia
  julia> cl == copy(cl)
  true
  ```

  * Also, `isequal` and `hash` is supported now.

    ```julia
    julia> d = Dict(cl => 42);

    julia> d[cl]
    42

    julia> d[copy(cl)]
    42
    ```

* `diff` supports higher order difference now.([#350])

* `diff` support `n` time steps lag now. ([#362])

  ```julia
  julia> diff(cl, 5)
  495x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-10 to 2001-12-31
  │            │ Close  │
  ├────────────┼────────┤
  │ 2000-01-10 │ -14.19 │
  │ 2000-01-11 │ -9.75  │
  │ 2000-01-12 │ -16.81 │
     ⋮
  │ 2001-12-27 │ 0.45   │
  │ 2001-12-28 │ 1.76   │
  │ 2001-12-31 │ 0.9    │
  ```

* New keyword argument for `readtimearray`: `header::Bool`. ([#358])

* `TimeArray` supports `all()` and `any()` now. ([#356], [#359])

  ```julia
  julia> ta
  3x2 TimeSeries.TimeArray{Int64,2,Date,Array{Int64,2}} 2000-01-03 to 2000-01-05
  │            │ _1    │ _2    │
  ├────────────┼───────┼───────┤
  │ 2000-01-03 │ 1     │ 2     │
  │ 2000-01-04 │ 3     │ 4     │
  │ 2000-01-05 │ 5     │ 6     │

  julia> all(ta .> 3, 2)
  3x1 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
  │            │ all   │
  ├────────────┼───────┤
  │ 2000-01-03 │ false │
  │ 2000-01-04 │ false │
  │ 2000-01-05 │ true  │
  ```


[#350]: https://github.com/JuliaStats/TimeSeries.jl/pull/350
[#352]: https://github.com/JuliaStats/TimeSeries.jl/pull/352
[#356]: https://github.com/JuliaStats/TimeSeries.jl/pull/356
[#357]: https://github.com/JuliaStats/TimeSeries.jl/pull/357
[#358]: https://github.com/JuliaStats/TimeSeries.jl/pull/358
[#359]: https://github.com/JuliaStats/TimeSeries.jl/pull/359
[#361]: https://github.com/JuliaStats/TimeSeries.jl/pull/361
[#362]: https://github.com/JuliaStats/TimeSeries.jl/pull/362
[#363]: https://github.com/JuliaStats/TimeSeries.jl/pull/363


### 0.11.0

* Dropping 0.5 support. (issue [#327])

* `TimeArray` constructor, `merge`, `update`, `vcat` and `rename`
  will throw typed exceptions. (issue [#322])

* Signature of `moving` becomes

  ```julia
    moving(f, ta::TimeArray, window; padding=false)
  ```

  , in order to support do-syntax. The original one is deprecated. (issue [#334])

* Signature of `upto` becomes

  ```julia
    moving(f, ta::TimeArray, window; padding=false)
  ```

  , in order to support do-syntax. The original one is deprecated. (issue [#337])

* `map` supports callable object. (issue [#339])

  ```julia
  struct T end
  (::T)(timestamp, x) = (timestamp, x + 42)

  t = T()

  map(t, ta)
  ```

* `hcat` support. Given two `TimeArray` which have same timestamp,

  ```julia
    [ta1 ta2]
  ```

  can perform faster than ```merge(ta1, ta2)``` in this case.
  (issue [#341])

* Support more reduction functions of Base. (issue [#338])
    * `sum`
    * `mean`
    * `std`
    * `var`

  e.g.
  ```julia
    sum(ta)  # same as sum(ta, 1), and it's equivalent to moving(sum, ta, length(ta))
    sum(ta, 2)
  ```

* Support cumulative prod `cumprod`. (issue [#338])

* Support `eachindex(ta)`. (issue [#336])

[#322]: https://github.com/JuliaStats/TimeSeries.jl/pull/322
[#327]: https://github.com/JuliaStats/TimeSeries.jl/pull/327
[#334]: https://github.com/JuliaStats/TimeSeries.jl/pull/334
[#336]: https://github.com/JuliaStats/TimeSeries.jl/pull/336
[#337]: https://github.com/JuliaStats/TimeSeries.jl/pull/337
[#338]: https://github.com/JuliaStats/TimeSeries.jl/pull/338
[#339]: https://github.com/JuliaStats/TimeSeries.jl/pull/339
[#341]: https://github.com/JuliaStats/TimeSeries.jl/pull/341

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
