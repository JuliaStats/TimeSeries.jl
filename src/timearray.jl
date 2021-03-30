###### type definition ##########

using Base: @propagate_inbounds

import Base: convert, copy, length, show, getindex, iterate,
             lastindex, size, eachindex, ==, isequal, hash, ndims,
             getproperty, propertynames, values

abstract type AbstractTimeSeries{T,N,D} end

"""
    TimeArray{T,N,D<:TimeType,A<:AbstractArray{T,N}} <: AbstractTimeSeries{T,N,D}

# Constructors

    TimeArray(timestamp, values[, colnames, meta = nothing])
    TimeArray(ta::TimeArray; timestamp, values, colnames, meta)
    TimeArray(data::NamedTuple, timestamp = :datetime, meta)
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
            unchecked = false) where {T,N,D<:TimeType,A<:AbstractArray{T,N}}
        nrow = size(values, 1)
        ncol = size(values, 2)
        colnames = copy(colnames)

        unchecked && return new(timestamp, values, replace_dupes!(colnames), meta)

        nrow != length(timestamp) && throw(DimensionMismatch("values must match length of timestamp"))
        ncol != length(colnames) && throw(DimensionMismatch("column names must match width of array"))

        issorted(timestamp) && return new(
            timestamp, values, replace_dupes!(colnames), meta)

        timestamp_r = reverse(timestamp)
        issorted(timestamp_r) && return new(
            timestamp_r, reverse(values, dims = 1), replace_dupes!(colnames), meta)

        throw(ArgumentError("timestamps must be monotonic"))
    end
end

###### outer constructor ########

TimeArray(d::AbstractVector{D}, v::AbstractArray{T,N},
          c::Vector{Symbol} = gen_colnames(size(v, 2)),
          m::Any = nothing; args...) where {T,N,D<:TimeType} =
    TimeArray{T,N,D,typeof(v)}(d, v, c, m; args...)

TimeArray(d::D, v::AbstractArray{T,N},
          c::Vector{Symbol} = gen_colnames(size(v, 2)),
          m::Any = nothing; args...) where {T,N,D<:TimeType} =
    TimeArray{T,N,D,typeof(v)}([d], v, c, m; args...)

TimeArray(ta::TimeArray;
          timestamp = _timestamp(ta), values = _values(ta),
          colnames = _colnames(ta), meta = _meta(ta), args...) =
    TimeArray(timestamp, values, colnames, meta; args...)

function TimeArray(data::NamedTuple; timestamp::Symbol, meta = nothing, args...)
    columns = (key for key in keys(data) if key != timestamp)
    dat = hcat((data[key] for key in columns)...)
    TimeArray(data[timestamp], dat, collect(columns), meta; args...)
end

###### conversion ###############

convert(::Type{TimeArray{Float64,N}}, x::TimeArray{Bool,N}) where N =
    TimeArray(timestamp(x), Float64.(values(x)), colnames(x), meta(x); unchecked = true)

convert(x::TimeArray{Bool,N}) where N =
    convert(TimeArray{Float64,N}, x::TimeArray{Bool,N})

###### copy ###############

copy(ta::TimeArray) =
    TimeArray(timestamp(ta), values(ta), colnames(ta), meta(ta); unchecked = true)

###### length ###################

length(ata::AbstractTimeSeries) = length(timestamp(ata))

###### size #####################

size(ta::TimeArray) = size(values(ta))
size(ta::TimeArray, dim) = size(values(ta), dim)

###### ndims #####################

ndims(ta::AbstractTimeSeries{T,N}) where {T,N} = N

###### iteration protocol ########

@generated function iterate(ta::AbstractTimeSeries{T,N}, i = 1) where {T,N}
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
x.values    == y.values    &&
x.colnames  == y.colnames  &&
x.meta      == y.meta
```
"""
==

# Other type info is not helpful for assertion.
# e.g.
#      1.0 == 1
#      Date(2111, 1, 1) == DateTime(2111, 1, 1)
==(x::TimeArray{T,N}, y::TimeArray{S,M}) where {T,S,N,M} = false
==(x::TimeArray{T,N}, y::TimeArray{S,N}) where {T,S,N} =
    all(f -> getfield(x, f) == getfield(y, f), fieldnames(TimeArray))

isequal(x::TimeArray{T,N}, y::TimeArray{S,M}) where {T,S,N,M} = false
isequal(x::TimeArray{T,N}, y::TimeArray{S,N}) where {T,S,N} =
    all(f -> isequal(getfield(x, f), getfield(y, f)), fieldnames(TimeArray))

# support for Dict
hash(x::TimeArray, h::UInt) =
    sum(f -> hash(getfield(x, f), h), fieldnames(TimeArray))

###### eltype #####################

Base.eltype(::AbstractTimeSeries{T,1,D}) where {T,D} = Tuple{D,T}
Base.eltype(::AbstractTimeSeries{T,2,D}) where {T,D} = Tuple{D,Vector{T}}

###### show #####################

@inline _showval(v::Any) = repr(v)
@inline _showval(v::Number) = string(v)
@inline _showval(v::AbstractFloat) =
    ifelse(isnan(v), MISSING, string(round(v, digits=DECIMALS)))

"""
calculate the paging

```
> using MarketData
> AAPL  # this function will return `UnitRange{Int64}[1:9, 10:12]`
```
"""
@inline function _showpages(dcol::Int, timewidth::Int, colwidth::Array{Int})
    ret = UnitRange{Int}[]
    c = dcol - timewidth - 5
    last_i = 1
    for i in eachindex(colwidth)
        w = colwidth[i] + 3
        if c - w < 0
            push!(ret, last_i:i-1)
            # next page
            c = dcol - timewidth - 5 - w
            last_i = i
        elseif i == length(colwidth)
            push!(ret, last_i:i)
        else
            c -= w
        end
    end
    ret
end

function print_time_array(io::IO, ta::TimeArray{T}, short=false, allcols=false) where T
    # summary line
    nrow = size(values(ta), 1)
    ncol = size(values(ta), 2)

    print(io, "$(nrow)×$(ncol) $(typeof(ta))")
    if nrow != 0
        print(io, " $(timestamp(ta)[1]) to $(timestamp(ta)[end])")
    else  # e.g. TimeArray(Date[], [])
        return
    end

    short && return
    println(io)

    # calculate column withs
    drow, dcol = displaysize(io)
    res_row    = 9  # number of reserved rows: summary line, label line ... etc
    half_row   = floor(Int, (drow - res_row) / 2)
    add_row    = (drow - res_row) % 2

    if nrow > (drow - res_row)
        tophalf = 1:(half_row + add_row)
        bothalf = (nrow - half_row + 1):nrow
        strs = _showval.(@view values(ta)[[tophalf; bothalf], :])
        ts   = @view timestamp(ta)[[tophalf; bothalf]]
    else
        tophalf = 0
        bothalf = 0
        strs = _showval.(values(ta))
        ts   = timestamp(ta)
    end

    colwidth = maximum(
        [textwidth.(string.(colnames(ta)))'; textwidth.(strs); fill(5, ncol)'],
        dims = 1)

    # paging
    spacetime = textwidth(string(ts[1]))
    pages = _showpages(dcol, spacetime, colwidth)

    # print all columns?
    if allcols 
        for p in pages
            islastpage = p == last(pages)
            _print_page(io, p, ta, 
                spacetime, colwidth, nrow, drow, res_row, tophalf, bothalf, 
                islastpage ? 1 : 2)
            if length(pages) > 1 && !islastpage
                print(io,"\n\n")
            end
        end
        println(io)
    else
        # print first page and omitted columns message
        _print_page(io, pages[1], ta, 
            spacetime, colwidth, nrow, drow, res_row, tophalf, bothalf, 
            length(pages))
        
        if length(pages) > 1
            pndtcols = last(last(pages)) - first(pages[2]) + 1
            println(io)
            printstyled(io, lpad("$pndtcols columns omitted", dcol), color=:cyan)
        end
    end
end

"""
    _print_page

Helper function to print a single page of the `TimeArray`
"""
function _print_page(io::IO, p::UnitRange{Int}, ta::TimeArray, spacetime, 
    colwidth, nrow, drow, res_row, tophalf, bothalf, pages) 
    
    strs = _showval.(values(ta))
    ts = timestamp(ta)
    last = pages > 1 ? "│\u22EF" : "│"

    # row label line
    ## e.g. | Open  | High  | Low   | Close  |
    print(io, "│", " "^(spacetime + 2))
    for (name, w) in zip(colnames(ta)[p], colwidth[p])
        print(io, "│ ", _rpad(name, w + 1))
    end
    println(io, last)

    ## e.g. ├───────┼───────┼───────┼────────┤
    print(io, "├", "─"^(spacetime + 2))
    for w in colwidth[p]
        print(io, "┼", "─"^(w + 2))
    end
    print(io, "┤")

    # timestamp and values line
    if nrow > (drow - res_row)
        
        # print bottom part
        for i in tophalf
            println(io)
            print(io, "│ ", ts[i], " ")
            for j in p
                print(io, "│ ", _rpad(strs[i, j], colwidth[j] + 1))
            end
            print(io, i % 3 == 0 ? last : "│")
        end

        # print vdots part
        println(io)
        print(io, "│ ", _rpad("\u22EE", spacetime + 1))
        for j in p
            print(io, "│ ", _rpad("\u22EE", colwidth[j] + 1))
        end
        # print(io, pages > 1 ? "│\u22F1" : "│")
        print(io, "│")

        # print bottom part
        for i in (length(bothalf) - 1):-1:0
            i = size(strs, 1) - i
            println(io)
            print(io, "│ ", ts[i], " ")
            for j in p
                print(io, "│ ", _rpad(strs[i, j], colwidth[j] + 1))
            end
            print(io, i % 3 == 0 ? last : "│")
        end

    else
        # print all rows
        for i in 1:nrow
            println(io)
            print(io, "│ ", ts[i], " ")
            for j in p
                print(io, "│ ", _rpad(strs[i, j], colwidth[j] + 1))
            end
            print(io, i % 3 == 0 ? last : "│")
        end
    end
end

Base.summary(io::IO, ta::TimeArray) = print_time_array(io, ta, true)

Base.show(io::IO, ta::TimeArray) = 
    print_time_array(io, ta, false, get(io, :limit, true))
Base.show(io::IO, ::MIME"text/plain", ta::TimeArray) = 
    print_time_array(io, ta, false, !get(io, :limit, false))
Base.show(ta::TimeArray) = 
    print_time_array(stdout, ta, false, true)


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
@propagate_inbounds getindex(ta::TimeArray{T,1}, r::UnitRange{<:Integer}) where T =
    TimeArray(timestamp(ta)[r], values(ta)[r], colnames(ta), meta(ta))

# array of rows
@propagate_inbounds getindex(ta::TimeArray, a::AbstractVector{<:Integer}) =
    TimeArray(timestamp(ta)[a], values(ta)[a, :], colnames(ta), meta(ta))

# array of 1d rows
@propagate_inbounds getindex(ta::TimeArray{T,1}, a::AbstractVector{<:Integer}) where T =
    TimeArray(timestamp(ta)[a], values(ta)[a], colnames(ta), meta(ta))

# single column by name
@propagate_inbounds function getindex(ta::TimeArray, s::Symbol)
    n = findcol(ta, s)
    TimeArray(timestamp(ta), values(ta)[:, n], Symbol[s], meta(ta), unchecked = true)
end

# array of columns by name
@propagate_inbounds getindex(ta::TimeArray, ss::Symbol...) = getindex(ta, collect(ss))
@propagate_inbounds getindex(ta::TimeArray, ss::Vector{Symbol}) =
    TimeArray(ta; values = values(ta)[:, map(s -> findcol(ta, s), ss)], colnames = ss)

# ta[rows, cols]
@propagate_inbounds getindex(ta::TimeArray,
         rows::Union{AbstractVector{<:Integer},Colon},
         cols::AbstractVector{Symbol}) =
    TimeArray(
        ta;
        timestamp = timestamp(ta)[rows],
        values = values(ta)[rows, map(s -> findcol(ta, s), cols)],
        colnames = cols,
        unchecked = true)

# ta[n, cols]
@propagate_inbounds getindex(ta::TimeArray, n::Integer, cols) =
    getindex(ta, [n], cols)

# ta[rows, col]
@propagate_inbounds getindex(ta::TimeArray, rows, col::Symbol) =
    getindex(ta, rows, [col])

# ta[n, col]
@propagate_inbounds getindex(ta::TimeArray, n::Integer, col::Symbol) =
    getindex(ta, [n], [col])

# single date
@propagate_inbounds function getindex(ta::TimeArray{T,N,D}, d::D) where {T,N,D}
    idxs = searchsorted(timestamp(ta), d)
    length(idxs) == 1 ? ta[idxs[1]] : nothing
end

# multiple dates
@propagate_inbounds function getindex(ta::TimeArray{T,N,D}, dates::Vector{D}) where {T,N,D}
    dates = sort(dates)
    idxs, _ = overlap(timestamp(ta), dates)
    ta[idxs]
end

# StepRange{Date,...}
@propagate_inbounds getindex(ta::TimeArray{T,N,D}, r::StepRange{D}) where {T,N,D} = ta[collect(r)]

@propagate_inbounds getindex(ta::TimeArray, k::TimeArray{Bool,1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(timestamp(ta)) .== d]

# Define end keyword
lastindex(ta::TimeArray, d::Integer = 1) =
    (d == 1) ? length(timestamp(ta)) :
    (d == 2) ? length(colnames(ta)) :
    1

eachindex(ta::TimeArray) = Base.OneTo(length(timestamp(ta)))

###### getproperty/propertynames #################

getproperty(ta::AbstractTimeSeries, c::Symbol) = ta[c]

propertynames(ta::TimeArray) = colnames(ta)

###### element wrapers ###########

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
_values(ta::TimeArray)    = getfield(ta, :values)
_colnames(ta::TimeArray)  = getfield(ta, :colnames)
_meta(ta::TimeArray)      = getfield(ta, :meta)
