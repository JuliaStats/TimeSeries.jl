###### type definition ##########

import Base: convert, copy, length, show, getindex, iterate,
             lastindex, size, eachindex, ==, isequal, hash, ndims

abstract type AbstractTimeSeries{T,N,D} end

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

        unchecked && return new(timestamp, values, replace_dupes(colnames), meta)

        nrow != length(timestamp) && throw(DimensionMismatch("values must match length of timestamp"))
        ncol != length(colnames) && throw(DimensionMismatch("column names must match width of array"))

        _issorted_and_unique(timestamp) && return new(
            timestamp, values, replace_dupes(colnames), meta)

        timestamp_r = reverse(timestamp)
        _issorted_and_unique(timestamp_r) && return new(
            timestamp_r, reverse(values, dims = 1), replace_dupes(colnames), meta)

        throw(ArgumentError("timestamps must be strictly monotonic"))
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

###### conversion ###############

convert(::Type{TimeArray{Float64,N}}, x::TimeArray{Bool,N}) where N =
    TimeArray(x.timestamp, Float64.(x.values), x.colnames, x.meta; unchecked = true)

convert(x::TimeArray{Bool,N}) where N =
    convert(TimeArray{Float64,N}, x::TimeArray{Bool,N})

###### copy ###############

copy(ta::TimeArray) =
    TimeArray(ta.timestamp, ta.values, ta.colnames, ta.meta; unchecked = true)

###### length ###################

length(ata::AbstractTimeSeries) = length(timestamp(ata))

###### size #####################

size(ta::TimeArray) = size(ta.values)
size(ta::TimeArray, dim) = size(ta.values, dim)

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
    c = dcol - timewidth - 4
    last_i = 1
    for i in eachindex(colwidth)
        w = colwidth[i] + 3
        if c - w < 0
            push!(ret, last_i:i-1)
            # next page
            c = dcol - timewidth - 4 - w
            last_i = i
        elseif i == length(colwidth)
            push!(ret, last_i:i)
        else
            c -= w
        end
    end
    ret
end

function show(io::IO, ta::TimeArray{T}) where T
    # summary line
    nrow = size(ta.values, 1)
    ncol = size(ta.values, 2)

    print(io, "$(nrow)×$(ncol) $(typeof(ta))")
    if nrow != 0
        println(io, " $(ta.timestamp[1]) to $(ta.timestamp[end])")
    else  # e.g. TimeArray(Date[], [])
        return
    end

    # calculate column withs
    drow, dcol = displaysize(io)
    res_row    = 7  # number of reserved rows: summary line, lable line ... etc
    half_row   = floor(Int, (drow - res_row) / 2)
    add_row    = (drow - res_row) % 2

    if nrow > (drow - res_row)
        tophalf = 1:(half_row + add_row)
        bothalf = (nrow - half_row + 1):nrow
        strs = _showval.(@view ta.values[[tophalf; bothalf], :])
        ts   = @view ta.timestamp[[tophalf; bothalf]]
    else
        strs = _showval.(ta.values)
        ts   = ta.timestamp
    end

    colwidth = maximum(
        [textwidth.(string.(ta.colnames))'; textwidth.(strs); fill(5, ncol)'],
        dims = 1)

    # paging
    spacetime = textwidth(string(ts[1]))
    pages = _showpages(dcol, spacetime, colwidth)

    for p ∈ pages
        # row label line
        ## e.g. | Open  | High  | Low   | Close  |
        print(io, "│", " "^(spacetime + 2))
        for (name, w) in zip(ta.colnames[p], colwidth[p])
            print(io, "│ ", rpad(name, w + 1))
        end
        println(io, "│")
        ## e.g. ├───────┼───────┼───────┼────────┤
        print(io, "├", "─"^(spacetime + 2))
        for w in colwidth[p]
            print(io, "┼", "─"^(w + 2))
        end
        print(io, "┤")

        # timestamp and values line
        if nrow > (drow - res_row)
            for i in tophalf
                println(io)
                print(io, "│ ", ts[i], " ")
                for j in p
                    print(io, "│ ", rpad(strs[i, j], colwidth[j] + 1))
                end
                print(io, "│")
            end

            print(io, "\n   \u22EE")

            for i in (length(bothalf) - 1):-1:0
                i = size(strs, 1) - i
                println(io)
                print(io, "│ ", ts[i], " ")
                for j in p
                    print(io, "│ ", rpad(strs[i, j], colwidth[j] + 1))
                end
                print(io, "│")
            end

        else
            for i in 1:nrow
                println(io)
                print(io, "│ ", ts[i], " ")
                for j in p
                    print(io, "│ ", rpad(strs[i, j], colwidth[j] + 1))
                end
                print(io, "│")
            end
        end

        if length(pages) > 1 && p != pages[end]
            print(io, "\n\n")
        end
    end  # for p ∈ pages
end

###### getindex #################

# single row
getindex(ta::TimeArray, n::Integer) =
    # avoid conversion to column vector
    TimeArray(ta.timestamp[n], ta.values[n:n, :], ta.colnames, ta.meta)

# single row 1d
getindex(ta::TimeArray{T,1}, n::Integer) where {T} =
    TimeArray(ta.timestamp[n], ta.values[[n]], ta.colnames, ta.meta)

# range of rows
getindex(ta::TimeArray, r::UnitRange{<:Integer}) =
    TimeArray(ta.timestamp[r], ta.values[r, :], ta.colnames, ta.meta)

# range of 1d rows
getindex(ta::TimeArray{T,1}, r::UnitRange{<:Integer}) where T =
    TimeArray(ta.timestamp[r], ta.values[r], ta.colnames, ta.meta)

# array of rows
getindex(ta::TimeArray, a::AbstractVector{<:Integer}) =
    TimeArray(ta.timestamp[a], ta.values[a, :], ta.colnames, ta.meta)

# array of 1d rows
getindex(ta::TimeArray{T,1}, a::AbstractVector{<:Integer}) where T =
    TimeArray(ta.timestamp[a], ta.values[a], ta.colnames, ta.meta)

# single column by name
function getindex(ta::TimeArray, s::Symbol)
    n = findfirst(isequal(s), colnames(ta))
    TimeArray(ta.timestamp, ta.values[:, n], Symbol[s], ta.meta, unchecked = true)
end

# array of columns by name
function getindex(ta::TimeArray, ss::Symbol...)
    ns = [findfirst(isequal(s), colnames(ta)) for s in ss]
    TimeArray(ta.timestamp, ta.values[:, ns], collect(ss), ta.meta)
end

# single date
function getindex(ta::TimeArray{T,N,D}, d::D) where {T,N,D}
    idxs = searchsorted(ta.timestamp, d)
    length(idxs) == 1 ? ta[idxs[1]] : nothing
end

# multiple dates
function getindex(ta::TimeArray{T,N,D}, dates::Vector{D}) where {T,N,D}
    dates = sort(dates)
    idxs, _ = overlap(ta.timestamp, dates)
    ta[idxs]
end

# StepRange{Date,...}
getindex(ta::TimeArray{T,N,D}, r::StepRange{D}) where {T,N,D} = ta[collect(r)]

getindex(ta::TimeArray, k::TimeArray{Bool,1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]

# Define end keyword
lastindex(ta::TimeArray) = length(ta.timestamp)

eachindex(ta::TimeArray) = Base.OneTo(length(ta.timestamp))
