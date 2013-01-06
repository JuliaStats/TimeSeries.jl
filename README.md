Low-level infrastructure code for getting data into a Julian data structure.

So far, there are only four functions inside three files:

`read_stock` that converts a csv file into a time series `DataFrame`    

`equity_curve` that returns the same-length `DataVector` by padding the first value with 1.0.

`moving` that returns a `DataArray` with padded `NAs`.

`moving!` that returns a modified `DataFrame` with padded `NAs`.

