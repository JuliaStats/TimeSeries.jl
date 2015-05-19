### 0.5.10 (not tagged yet)

* changed references of flipud(A) to flipdim(A,1)_
* changed references of round(x) to iround(Integer,x)_
* changed references of iround(Integer,x) back to round(Integer,x)_
* changed references of int(x) to round(Int64, x)
* changed references of float(x) to map(Float64, x)
* changed references of [a] to [a;] in a comprehension found in the by() method

### 0.5.9

Added kwarg argument `format` to the `readtimearray` method to allow parsing datetime formats that are not 
currently supported.

Changed two references to `Range1` to `UnitRange`

Added import of Base.values. I had defined it first and I guess they like it so much they co-opted it. :)

### pre-0.5.8

Not currently documented.
