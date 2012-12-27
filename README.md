Low-level infrastructure code for getting data into a Julia data structure.

So far, there are only two functions:

`read_stock` that converts a csv file into a time series DataFrame    

`equity_curve` that returns the same-length `DataVec` by padding the first value with 1.0.

