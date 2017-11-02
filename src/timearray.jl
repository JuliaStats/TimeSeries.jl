###### type definition ##########

import Base: convert, length, show, getindex, start, next, done, isempty, endof,
             size, eachindex

abstract type AbstractTimeSeries end

struct TimeArray{T, N, D <: TimeType, A <: AbstractArray{T, N}} <: AbstractTimeSeries

    timestamp::Vector{D}
    values::A
    colnames::Vector{String}
    meta::Any

    function TimeArray{T, N, D, A}(
            timestamp::AbstractVector{D},
            values::A,
            colnames::Vector{String},
            meta::Any) where {T, N, D <: TimeType, A <: AbstractArray{T, N}}
        nrow, ncol = size(values, 1, 2)

        if nrow != length(timestamp)
            throw(DimensionMismatch("values must match length of timestamp"))
        elseif ncol != length(colnames)
            throw(DimensionMismatch("column names must match width of array"))
        elseif !allunique(timestamp)
            throw(ArgumentError("there are duplicate dates"))
        elseif !(issorted(timestamp) || issorted(timestamp, rev=true))
            throw(ArgumentError("dates are mangled"))
        elseif issorted(timestamp, rev=true)
            new(reverse(timestamp), flipdim(values, 1),
                replace_dupes(colnames), meta)
        else
            new(timestamp, values, replace_dupes(colnames), meta)
        end
    end
end

###### outer constructor ########

TimeArray(d::AbstractVector{D}, v::AbstractArray{T, N}, c::Vector{S},
          m::Any) where {T, N, D <: TimeType, S <: AbstractString} =
    TimeArray{T, N, D, typeof(v)}(d, v, map(String, c), m)
TimeArray(d::D, v::AbstractArray{T, N}, c::Vector{S},
          m::Any) where {T, N, D <: TimeType, S <: AbstractString} =
    TimeArray{T, N, D, typeof(v)}([d], v, map(String, c), m)

# when no column names are provided - meta is forced to nothing
TimeArray(d::AbstractVector{D}, v::AbstractArray) where {D <: TimeType} =
    TimeArray(d, v, fill("", size(v, 2)), nothing)
TimeArray(d::D, v::AbstractArray) where {D <: TimeType} =
    TimeArray([d], v, fill("", size(v, 2)), nothing)

# when no meta is provided
TimeArray(d::AbstractVector{D}, v::AbstractArray, c) where {D <: TimeType} =
    TimeArray(d, v, c, nothing)
TimeArray(d::D, v::AbstractArray, c) where {D <: TimeType} =
    TimeArray([d], v, c, nothing)

###### conversion ###############

convert(::Type{TimeArray{Float64, 1}}, x::TimeArray{Bool, 1}) =
    TimeArray(x.timestamp, map(Float64, x.values), x.colnames, x.meta)
convert(::Type{TimeArray{Float64, 2}}, x::TimeArray{Bool, 2}) =
    TimeArray(x.timestamp, map(Float64, x.values), x.colnames, x.meta)

convert(x::TimeArray{Bool, 1}) = convert(TimeArray{Float64, 1}, x::TimeArray{Bool, 1})
convert(x::TimeArray{Bool, 2}) = convert(TimeArray{Float64, 2}, x::TimeArray{Bool, 2})

###### length ###################

length(ata::AbstractTimeSeries) = length(ata.timestamp)

###### size #####################

size(ta::TimeArray, dim...) = size(ta.values, dim...)

###### iterator protocol #########

start(ta::TimeArray)   = 1
next(ta::TimeArray, i) = ((ta.timestamp[i], ta.values[i, :]), i + 1)
done(ta::TimeArray, i) = (i > length(ta))
isempty(ta::TimeArray) = (length(ta) == 0)

###### show #####################

@inline _showval(v::Any) = repr(v)
@inline _showval(v::Number) = string(v)
@inline _showval(v::AbstractFloat) =
    ifelse(isnan(v), MISSING, string(round(v, DECIMALS)))

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

function show(io::IO, ta::TimeArray{T}) where {T}

    # summary line
    nrow, ncol = size(ta.values, 1, 2)

    @printf(io, "%dx%d %s", nrow, ncol, typeof(ta))
    if nrow != 0
        @printf(io, " %s to %s\n", ta.timestamp[1], ta.timestamp[end])
    else # e.g. TimeArray(Date[], [])
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

    # NOTE: reshaping is a workaround in julia 0.6
    #       in 0.7, it can be:
    #         [strwidth.(ta.colnames)'; strwidth.(strs); fill(5, ncol)']
    colwidth = maximum([
        reshape(strwidth.(ta.colnames), 1, :);
        strwidth.(strs);
        reshape(fill(5, ncol), 1, :)], 1)

    # paging
    spacetime = strwidth(string(ts[1]))
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
function getindex(ta::TimeArray, n::Int)
    # avoid conversion to column vector
    TimeArray(ta.timestamp[n], ta.values[n:n, :], ta.colnames, ta.meta)
end

# single row 1d
function getindex(ta::TimeArray{T, 1}, n::Int) where {T}
    TimeArray(ta.timestamp[n], ta.values[[n]], ta.colnames, ta.meta)
end

# range of rows
function getindex(ta::TimeArray, r::UnitRange{Int})
    TimeArray(ta.timestamp[r], ta.values[r, :], ta.colnames, ta.meta)
end

# range of 1d rows
function getindex(ta::TimeArray{T, 1}, r::UnitRange{Int}) where {T}
    TimeArray(ta.timestamp[r], ta.values[r], ta.colnames, ta.meta)
end

# array of rows
function getindex(ta::TimeArray, a::AbstractVector{S}) where {S <: Integer}
    TimeArray(ta.timestamp[a], ta.values[a, :], ta.colnames, ta.meta)
end

# array of 1d rows
function getindex(ta::TimeArray{T, 1}, a::AbstractVector{S}) where {T, S <: Integer}
    TimeArray(ta.timestamp[a], ta.values[a], ta.colnames, ta.meta)
end

# single column by name
function getindex(ta::TimeArray, s::AbstractString)
    n = findfirst(ta.colnames, s)
    TimeArray(ta.timestamp, ta.values[:, n], String[s], ta.meta)
end

# array of columns by name
function getindex(ta::TimeArray, args::AbstractString...)
    ns = [findfirst(ta.colnames, a) for a in args]
    TimeArray(ta.timestamp, ta.values[:, ns], String[a for a in args], ta.meta)
end

# single date
function getindex(ta::TimeArray{T, N, D}, d::D) where {T, N, D}
    idxs = searchsorted(ta.timestamp, d)
    length(idxs) == 1 ? ta[idxs[1]] : nothing
end

# multiple dates
function getindex(ta::TimeArray{T, N, D}, dates::Vector{D}) where {T, N, D}
    dates = sort(dates)
    idxs, _ = overlaps(ta.timestamp, dates)
    ta[idxs]
end

# StepRange{Date,...}
getindex(ta::TimeArray{T, N, D}, r::StepRange{D}) where {T, N, D} =
    ta[collect(r)]

getindex(ta::TimeArray, k::TimeArray{Bool, 1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]

# Define end keyword
endof(ta::TimeArray) = length(ta.timestamp)

eachindex(ta::TimeArray) = Base.OneTo(length(ta.timestamp))

# helper methods for inner constructor
function find_dupes_index(cnames)
    idx = Int[]
    for c in 1:length(cnames)
        if contains(string(cnames[1:c-1]), cnames[c])
            push!(idx, c)
        end
    end
    idx
end

function replace_dupes(cnames)
    n=1
    while length(unique(cnames)) != length(cnames)
        ds = find_dupes_index(cnames)
        for d in ds
            if n == 1
                cnames[d] = string(cnames[d], "_$n")
            else
                cnames[d] = string(cnames[d][1:length(cnames[d])-length(string(n))-1], "_$n")
            end
        end
    n +=1
    end
    cnames
end
