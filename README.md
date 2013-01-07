Low-level infrastructure code for getting data into a Julian data structure.

So far, there are six functions:

`read_stock` that converts a csv file into a time series `DataFrame`    

`equity_curve` that returns the same-length `DataVector` by padding the first value with 1.0.

`moving` that returns a `DataArray` with padded `NAs`.

`moving!` that returns a modified `DataFrame` with padded `NAs`.

`lead` that returns a modified `DataArray` with padded `NAs`.

`lag` that returns a modified `DataArray` with padded `NAs`.


#### TODO

* `lead!` and `lag!` functions.
* `upto` and `upto!` functions.
* `ret` and `ret!` functions.
* `rsi` and `rsi!` functions.
