# JuliaData/Tables.jl integration

module TablesIntegration

using ..TimeSeries

using Tables


# S: the column names, including the extra column name for time index
# N: number of rows
# M: number of columns
struct TableIter{T<:AbstractTimeSeries,S,N,M}
    x::T
end

function TableIter(ta::T) where {T<:TimeArray}
    N, M = size(ta, 1), size(ta, 2) + 1
    col′ = TimeSeries.replace_dupes!([:timestamp; colnames(ta)])
    S = Tuple(col′)
    # TODO: `colnames = @view(col′[2:end])` doesn't work at this moment
    TableIter{T,S,N,M}(TimeArray(ta, colnames = col′[2:end], unchecked = true))
end

data(i::TableIter) = getfield(i, :x)

TimeSeries.timestamp(i::TableIter) = timestamp(data(i))
TimeSeries.colnames(i::TableIter)  = colnames(data(i))

Base.getindex(x::TableIter{<:TimeArray}, i::Integer) =
    i == 1 ? timestamp(x) : values(data(x)[colnames(x)[i - 1]])
Base.getindex(x::TableIter{<:TimeArray}, j::Integer, i::Integer) =
    i == 1 ? timestamp(x)[j] : values(data(x)[colnames(x)[i - 1]])[j]

Base.length(::TableIter{<:TimeArray,S,N,M}) where {S,N,M}    = M
Base.lastindex(::TableIter{<:TimeArray,S,N,M}) where {S,N,M} = M
Base.lastindex(::TableIter{<:TimeArray,S,N,M}, d::Integer) where {S,N,M} =
    ifelse(d == 1, N, ifelse(d == 2, M, 1))
Base.size(::TableIter{<:TimeArray,S,N,M}) where {S,N,M} = (N, M)

Base.propertynames(x::TableIter{<:TimeArray,S}) where {S} = S
Base.getproperty(x::TableIter{<:TimeArray,S}, c::Symbol) where {S} =
    c == S[1] ? timestamp(x) : values(getproperty(data(x), c))

function Base.iterate(x::TableIter, i::Integer = 1)
    i > length(x) && return nothing
    x[i], i + 1
end

Tables.rowaccess(::Type{<:TimeArray}) = true
Tables.rows(ta::TimeArray) = Tables.rows(Tables.columntable(ta))
Tables.columnaccess(::Type{<:TimeArray}) = true
Tables.columns(ta::TimeArray) = TableIter(ta)
Tables.columnnames(ta::TimeArray) = Tables.columnnames(TableIter(ta))
Tables.columnnames(i::TableIter{T, S}) where {T,S} = collect(Symbol, S)
Tables.getcolumn(ta::TimeArray, i::Int) = Tables.getcolumn(TableIter(ta), i)
Tables.getcolumn(ta::TimeArray, nm::Symbol) = Tables.getcolumn(TableIter(ta), nm)
Tables.getcolumn(i::TableIter, n::Int) = i[n]
Tables.getcolumn(i::TableIter, nm::Symbol) = getproperty(i, nm)
Tables.schema(ta::TimeArray) = Tables.schema(TableIter(ta))
Tables.schema(i::TableIter{T,S}) where {T,S} = Tables.Schema(S, coltypes(data(i)))

coltypes(x::TimeArray{T,N,D}) where {T,N,D} = (D, (T for _ ∈ 1:size(x, 2))...)


###############################################################################
#  Constructors
###############################################################################

function TimeSeries.TimeArray(x; timestamp::Symbol, timeparser::Base.Callable = identity,
                              unchecked = false)
    Tables.istable(x) || throw(ArgumentError("TimeArray requires a table as input"))

    sch = Tables.schema(x)
    names = sch.names
    (timestamp ∉ names) && throw(ArgumentError("time index `$timestamp` not found"))
    names′ = filter(!isequal(timestamp), collect(sch.names))

    cols = Tables.columns(x)
    val = mapreduce(n -> collect(Tables.getcolumn(cols, n)), hcat, names′)
    TimeArray(map(timeparser, Tables.getcolumn(cols, timestamp)), val, names′, x;
              unchecked = unchecked)
end

###############################################################################
#  eachrow/eachcol
###############################################################################

@static if VERSION ≥ v"1.1"


@doc """
    eachrow(x::TimeArray)

Return a row iterator baked by `Tables.rows`.

# Examples

```julia
for row ∈ eachrow(ohlc)
    time = row.timestamp
    price = row.Close
end
```
"""
Base.eachrow(x::TimeArray) = Tables.rows(x)

@doc """
    eachcol(x::TimeArray)

Return a column iterator baked by `Tables.columns`.
"""
Base.eachcol(x::TimeArray) = Tables.columns(x)


end  # @static if VERSION ≥ v"1.1"

end  # TablesIntegration
