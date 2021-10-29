###############################################################################
# AbstractTimeSeries
###############################################################################

"""
    AbstractTimeSeries{T}

An `AbstractTimeSeries{T}` is a table-like data structure with a time index and
named columns.
Where `T` denotes the type of time index.

In the case of multiple columns as compound index, `T <: Tuple`.
For instance, let `T = Tuple{Date,Time}` implies there are two columns
which forms the time index.

# Interfaces


## Dimension and size

- `length`
- `ndims`
- `size`
- `axes`

- `copy`
- `deepcopy`
- `similar`

- `names`
- `rename`
- `rename!`

- `hcat`
- `vcat`

"""
abstract type AbstractTimeSeries{T} end

Base.names(ats::AbstractTimeSeries) = getfield(ats, :names)


Tables.istable(::Type{<:AbstractTimeSeries}) = true

Tables.columnaccess(::Type{<:AbstractTimeSeries}) = true
Tables.columns(ats::AbstractTimeSeries) = ats

Tables.rowaccess(::Type{<:AbstractTimeSeries}) = true
# TODO
# Tables.rows(x::AbstractTimeSeries)

Tables.schema(ats::AbstractTimeSeries) = Tables.Schema(names(ats), #= TODO =#)
