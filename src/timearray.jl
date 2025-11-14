###### type definition ##########

using Base: @propagate_inbounds

import Base:
    convert,
    copy,
    length,
    show,
    getindex,
    iterate,
    lastindex,
    size,
    eachindex,
    ==,
    isequal,
    hash,
    ndims,
    getproperty,
    propertynames,
    values

abstract type AbstractTimeSeries{T,N,D} end

"""
    TimeArray{T,N,D<:TimeType,A<:AbstractArray{T,N}} <: AbstractTimeSeries{T,N,D}

# Constructors

    TimeArray(timestamp, values[, colnames, meta = nothing])
    TimeArray(ta::TimeArray; timestamp, values, colnames, meta)
    TimeArray(data::NamedTuple; timestamp, meta = nothing)
    TimeArray(table; timestamp::Symbol, timeparser::Callable = identity)

The second constructor yields a new `TimeArray` with the new given fields.
Note that the unchanged fields will be shared, there aren't any copy for the
underlying arrays.

The third constructor builds a `TimeArray` from a `NamedTuple`.

# Arguments

  - `timestamp::AbstractVector{<:TimeType}`: a vector of sorted timestamps,

  - `timestamp::Symbol`: the column name of the time index from the source table.
    The constructor is used for the Tables.jl package integration.
  - `values::AbstractArray`: a data vector or matrix. Its number of rows
    should match the length of `timestamp`.
  - `colnames::Vector{Symbol}`: the column names. Its length should match
    the column of `values`.
  - `meta::Any`: a user-defined metadata.
  - `timeparser::Callable`: a mapping function for converting the source time index.
    For instance, `Dates.unix2datetime` is a common case.

# Examples

    data = (datetime = [DateTime(2018, 11, 21, 12, 0), DateTime(2018, 11, 21, 13, 0)],
            col1 = [10.2, 11.2],
            col2 = [20.2, 21.2],
            col3 = [30.2, 31.2])
    ta = TimeArray(data; timestamp = :datetime, meta = "Example")
"""
struct TimeArray{T,N,D<:TimeType,A<:AbstractArray{T,N}} <: AbstractTimeSeries{T,N,D}
    timestamp::Vector{D}
    values::A
    colnames::Vector{Symbol}
    meta::Any

    function TimeArray{T,N,D,A}(
        timestamp::AbstractVector{D},
        values::A,
        colnames::Vector{Symbol},
        meta::Any;
        unchecked=false,
    ) where {T,N,D<:TimeType,A<:AbstractArray{T,N}}
        nrow = size(values, 1)
        ncol = size(values, 2)
        colnames = copy(colnames)

        unchecked && return new(timestamp, values, replace_dupes!(colnames), meta)

        nrow != length(timestamp) &&
            throw(DimensionMismatch("values must match length of timestamp"))
        ncol != length(colnames) &&
            throw(DimensionMismatch("column names must match width of array"))

        issorted(timestamp) && return new(timestamp, values, replace_dupes!(colnames), meta)

        timestamp_r = reverse(timestamp)
        issorted(timestamp_r) &&
            return new(timestamp_r, reverse(values; dims=1), replace_dupes!(colnames), meta)

        throw(ArgumentError("timestamps must be monotonic"))
    end
end

###### outer constructor ########

function TimeArray(
    d::AbstractVector{D},
    v::AbstractArray{T,N},
    c::Vector{Symbol}=gen_colnames(size(v, 2)),
    m::Any=nothing;
    args...,
) where {T,N,D<:TimeType}
    return TimeArray{T,N,D,typeof(v)}(d, v, c, m; args...)
end

function TimeArray(
    d::D,
    v::AbstractArray{T,N},
    c::Vector{Symbol}=gen_colnames(size(v, 2)),
    m::Any=nothing;
    args...,
) where {T,N,D<:TimeType}
    return TimeArray{T,N,D,typeof(v)}([d], v, c, m; args...)
end

function TimeArray(
    ta::TimeArray;
    timestamp=_timestamp(ta),
    values=_values(ta),
    colnames=_colnames(ta),
    meta=_meta(ta),
    args...,
)
    return TimeArray(timestamp, values, colnames, meta; args...)
end

function TimeArray(data::NamedTuple; timestamp::Symbol, meta=nothing, args...)
    columns = (key for key in keys(data) if key != timestamp)
    dat = hcat((data[key] for key in columns)...)
    return TimeArray(data[timestamp], dat, collect(columns), meta; args...)
end

###### conversion ###############

function convert(::Type{TimeArray{Float64,N}}, x::TimeArray{Bool,N}) where {N}
    return TimeArray(
        timestamp(x), Float64.(values(x)), colnames(x), meta(x); unchecked=true
    )
end

function convert(x::TimeArray{Bool,N}) where {N}
    return convert(TimeArray{Float64,N}, x::TimeArray{Bool,N})
end

###### copy ###############

function copy(ta::TimeArray)
    return TimeArray(timestamp(ta), values(ta), colnames(ta), meta(ta); unchecked=true)
end

###### length ###################

length(ata::AbstractTimeSeries) = length(timestamp(ata))

###### size #####################

size(ta::TimeArray) = size(values(ta))
size(ta::TimeArray, dim) = size(values(ta), dim)

###### ndims #####################

ndims(ta::AbstractTimeSeries{T,N}) where {T,N} = N

###### iteration protocol ########

@generated function iterate(ta::AbstractTimeSeries{T,N}, i=1) where {T,N}
    val = (N == 1) ? :(values(ta)[i]) : :(values(ta)[i, :])

    quote
        i > length(ta) && return nothing
        ((timestamp(ta)[i], $val), i + 1)
    end
end

###### equal ####################

"""
    ==(x::TimeArray, y::TimeArray)

If `true`, all fields of `x` and `y` should be equal,
meaning that the two `TimeArray`s have the same values at the same points in time,
the same colnames and the same metadata.

Implies

```julia
x.timestamp == y.timestamp &&
    x.values == y.values &&
    x.colnames == y.colnames &&
    x.meta == y.meta
```
"""
==

# Other type info is not helpful for assertion.
# e.g.
#      1.0 == 1
#      Date(2111, 1, 1) == DateTime(2111, 1, 1)
==(x::TimeArray{T,N}, y::TimeArray{S,M}) where {T,S,N,M} = false
function ==(x::TimeArray{T,N}, y::TimeArray{S,N}) where {T,S,N}
    return all(f -> getfield(x, f) == getfield(y, f), fieldnames(TimeArray))
end

isequal(x::TimeArray{T,N}, y::TimeArray{S,M}) where {T,S,N,M} = false
function isequal(x::TimeArray{T,N}, y::TimeArray{S,N}) where {T,S,N}
    return all(f -> isequal(getfield(x, f), getfield(y, f)), fieldnames(TimeArray))
end

# support for Dict
hash(x::TimeArray, h::UInt) = sum(f -> hash(getfield(x, f), h), fieldnames(TimeArray))

###### eltype #####################

Base.eltype(::AbstractTimeSeries{T,1,D}) where {T,D} = Tuple{D,T}
Base.eltype(::AbstractTimeSeries{T,2,D}) where {T,D} = Tuple{D,Vector{T}}

###### show #####################
Base.summary(io::IO, ta::TimeArray) = show(io, ta)

function Base.show(io::IO, ta::TimeArray)
    nrow = size(values(ta), 1)
    ncol = size(values(ta), 2)
    print(io, "$(nrow)×$(ncol) $(typeof(ta))")
    if nrow != 0
        print(io, " $(timestamp(ta)[1]) to $(timestamp(ta)[end])")
    else  # e.g. TimeArray(Date[], [])
        return nothing
    end
end

@static if pkgversion(PrettyTables).major == 2
    # TODO: When PrettyTables v2 is more widely spread get rid off this and the compat
    function Base.show(
        io::IO,
        ::MIME"text/plain",
        ta::TimeArray;
        allrows=!get(io, :limit, false),
        allcols=!get(io, :limit, false),
    )
        nrow = size(values(ta), 1)
        ncol = size(values(ta), 2)

        show(io, ta) # summary line

        nrow == 0 && return nothing

        println(io)

        if allcols && allrows
            crop = :none
        elseif allcols
            crop = :vertical
        elseif allrows
            crop = :horizontal
        else
            crop = :both
        end

        data = hcat(timestamp(ta), values(ta))
        header = vcat("", string.(colnames(ta)))
        return pretty_table(
            io,
            data;
            header=header,
            newline_at_end=false,
            reserved_display_lines=2,
            row_label_alignment=:r,
            header_alignment=:l,
            crop=crop,
            vcrop_mode=:middle,
        )
    end
else
    function Base.show(
        io::IO,
        ::MIME"text/plain",
        ta::TimeArray;
        allrows=!get(io, :limit, false),
        allcols=!get(io, :limit, false),
    )
        nrow = size(values(ta), 1)
        ncol = size(values(ta), 2)

        show(io, ta) # summary line

        nrow == 0 && return nothing

        println(io)

        data = hcat(timestamp(ta), values(ta))
        header = vcat("", string.(colnames(ta)))
        return pretty_table(
            io,
            data;
            column_labels=header,
            new_line_at_end=false,
            reserved_display_lines=2,
            row_label_column_alignment=:r,
            column_label_alignment=:l,
            continuation_row_alignment=:c,
            fit_table_in_display_horizontally=!allcols, # replaced crop keyword for v3 of PrettyTables
            fit_table_in_display_vertically=!allrows,   # replaced crop keyword for v3 of PrettyTables
            vertical_crop_mode=:middle,
        )
    end
end

###### getindex #################

# the getindex function should return a new TimeArray, and copy data from
# the source, includes `timestamp`, `values` and `colnames`.

getindex(ta::TimeArray) = throw(BoundsError(typeof(ta), []))

# single row
@propagate_inbounds getindex(ta::TimeArray, n::Integer) =
# avoid conversion to column vector
    TimeArray(timestamp(ta)[n], values(ta)[n:n, :], colnames(ta), meta(ta))

# single row 1d
@propagate_inbounds getindex(ta::TimeArray{T,1}, n::Integer) where {T} =
    TimeArray(timestamp(ta)[n], values(ta)[[n]], colnames(ta), meta(ta))

# range of rows
@propagate_inbounds getindex(ta::TimeArray, r::UnitRange{<:Integer}) =
    TimeArray(timestamp(ta)[r], values(ta)[r, :], colnames(ta), meta(ta))

# range of 1d rows
@propagate_inbounds getindex(ta::TimeArray{T,1}, r::UnitRange{<:Integer}) where {T} =
    TimeArray(timestamp(ta)[r], values(ta)[r], colnames(ta), meta(ta))

# array of rows
@propagate_inbounds getindex(ta::TimeArray, a::AbstractVector{<:Integer}) =
    TimeArray(timestamp(ta)[a], values(ta)[a, :], colnames(ta), meta(ta))

# array of 1d rows
@propagate_inbounds getindex(ta::TimeArray{T,1}, a::AbstractVector{<:Integer}) where {T} =
    TimeArray(timestamp(ta)[a], values(ta)[a], colnames(ta), meta(ta))

# single column by name
@propagate_inbounds function getindex(ta::TimeArray, s::Symbol)
    n = findcol(ta, s)
    return TimeArray(timestamp(ta), values(ta)[:, n], Symbol[s], meta(ta); unchecked=true)
end

# array of columns by name
@propagate_inbounds getindex(ta::TimeArray, ss::Symbol...) = getindex(ta, collect(ss))
@propagate_inbounds getindex(ta::TimeArray, ss::Vector{Symbol}) =
    TimeArray(ta; values=values(ta)[:, map(s -> findcol(ta, s), ss)], colnames=ss)

# ta[rows, cols]
@propagate_inbounds getindex(
    ta::TimeArray,
    rows::Union{AbstractVector{<:Integer},Colon},
    cols::AbstractVector{Symbol},
) = TimeArray(
    ta;
    timestamp=timestamp(ta)[rows],
    values=values(ta)[rows, map(s -> findcol(ta, s), cols)],
    colnames=cols,
    unchecked=true,
)

# ta[n, cols]
@propagate_inbounds getindex(ta::TimeArray, n::Integer, cols) = getindex(ta, [n], cols)

# ta[rows, col]
@propagate_inbounds getindex(ta::TimeArray, rows, col::Symbol) = getindex(ta, rows, [col])

# ta[n, col]
@propagate_inbounds getindex(ta::TimeArray, n::Integer, col::Symbol) =
    getindex(ta, [n], [col])

# single date
@propagate_inbounds function getindex(ta::TimeArray{T,N,D}, d::D) where {T,N,D}
    idxs = searchsorted(timestamp(ta), d)
    return length(idxs) == 1 ? ta[idxs[1]] : nothing
end

# multiple dates
@propagate_inbounds function getindex(ta::TimeArray{T,N,D}, dates::Vector{D}) where {T,N,D}
    dates = sort(dates)
    idxs, _ = overlap(timestamp(ta), dates)
    return ta[idxs]
end

# StepRange{Date,...}
@propagate_inbounds getindex(ta::TimeArray{T,N,D}, r::StepRange{D}) where {T,N,D} =
    ta[collect(r)]

@propagate_inbounds getindex(ta::TimeArray, k::TimeArray{Bool,1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(timestamp(ta)) .== d]

# Define end keyword
function lastindex(ta::TimeArray, d::Integer=1)
    return if (d == 1)
        length(timestamp(ta))
    elseif (d == 2)
        length(colnames(ta))
    else
        1
    end
end

eachindex(ta::TimeArray) = Base.OneTo(length(timestamp(ta)))

###### getproperty/propertynames #################

getproperty(ta::AbstractTimeSeries, c::Symbol) = ta[c]

propertynames(ta::TimeArray) = colnames(ta)

###### element wrappers ###########

"""
    timestamp(ta::TimeArray)

Get the time index of a `TimeArray`.
"""
timestamp(ta::TimeArray) = getfield(ta, :timestamp)

"""
    values(ta::TimeArray)

Get the underlying value table of a `TimeArray`.
"""
values(ta::TimeArray) = getfield(ta, :values)

"""
    colnames(ta::TimeArray)

Get the column names of a `TimeArray`.

# Examples

```julia-repl
julia> colnames(ohlc)
4-element Array{Symbol,1}:
 :Open
 :High
 :Low
 :Close
```
"""
colnames(ta::TimeArray) = getfield(ta, :colnames)

"""
    meta(ta::TimeArray)

Get the user-defined metadata of a `TimeArray`.
"""
meta(ta::TimeArray) = getfield(ta, :meta)

# internal use, to avoid name collision
_timestamp(ta::TimeArray) = getfield(ta, :timestamp)
_values(ta::TimeArray) = getfield(ta, :values)
_colnames(ta::TimeArray) = getfield(ta, :colnames)
_meta(ta::TimeArray) = getfield(ta, :meta)
