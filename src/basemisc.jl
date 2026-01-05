# Misc. Base functions

Base.cumsum(ta::TimeArray, dim::Int=1) =
    TimeArray(ta.timestamp, cumsum(ta.values, dim), ta.colnames, ta.meta)
