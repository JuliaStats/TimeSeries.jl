# JuliaData/Tables.jl integration

module TablesIntegration

using ..TimeSeries

using Tables
using TableTraits
using IteratorInterfaceExtensions

# S: the column names, including the extra column name for time index
# N: number of rows
# M: number of columns
struct TableIter{T<:AbstractTimeSeries,S,N,M}
    x::T
end

function TableIter(ta::T) where {T<:TimeArray}
    N, M = size(ta, 1), size(ta, 2) + 1
    col_ = TimeSeries.replace_dupes!([:timestamp; colnames(ta)])
    S = Tuple(col_)
    # TODO: `colnames = @view(col′[2:end])` doesn't work at this moment
    return TableIter{T,S,N,M}(TimeArray(ta; colnames=col_[2:end], unchecked=true))
end

data(i::TableIter) = getfield(i, :x)

TimeSeries.timestamp(i::TableIter) = timestamp(data(i))
TimeSeries.colnames(i::TableIter) = colnames(data(i))

function Base.getindex(x::TableIter{<:TimeArray}, i::Integer)
    return i == 1 ? timestamp(x) : values(data(x)[colnames(x)[i - 1]])
end
function Base.getindex(x::TableIter{<:TimeArray}, j::Integer, i::Integer)
    return i == 1 ? timestamp(x)[j] : values(data(x)[colnames(x)[i - 1]])[j]
end

Base.length(::TableIter{<:TimeArray,S,N,M}) where {S,N,M} = M
Base.lastindex(::TableIter{<:TimeArray,S,N,M}) where {S,N,M} = M
function Base.lastindex(::TableIter{<:TimeArray,S,N,M}, d::Integer) where {S,N,M}
    return ifelse(d == 1, N, ifelse(d == 2, M, 1))
end
Base.size(::TableIter{<:TimeArray,S,N,M}) where {S,N,M} = (N, M)

Base.propertynames(x::TableIter{<:TimeArray,S}) where {S} = S
function Base.getproperty(x::TableIter{<:TimeArray,S}, c::Symbol) where {S}
    return c == S[1] ? timestamp(x) : values(getproperty(data(x), c))
end

function Base.iterate(x::TableIter, i::Integer=1)
    i > length(x) && return nothing
    return x[i], i + 1
end

Tables.istable(::Type{<:AbstractTimeSeries}) = true
Tables.rowaccess(::Type{<:TimeArray}) = true
Tables.rows(ta::TimeArray) = Tables.rows(Tables.columntable(ta))
Tables.columnaccess(::Type{<:TimeArray}) = true
Tables.columns(ta::TimeArray) = TableIter(ta)
Tables.columnnames(ta::TimeArray) = Tables.columnnames(TableIter(ta))
Tables.columnnames(i::TableIter{T,S}) where {T,S} = collect(Symbol, S)
Tables.getcolumn(ta::TimeArray, i::Int) = Tables.getcolumn(TableIter(ta), i)
Tables.getcolumn(ta::TimeArray, nm::Symbol) = Tables.getcolumn(TableIter(ta), nm)
Tables.getcolumn(i::TableIter, n::Int) = i[n]
Tables.getcolumn(i::TableIter, nm::Symbol) = getproperty(i, nm)
Tables.schema(ta::AbstractTimeSeries{T,N,D}) where {T,N,D} = Tables.schema(TableIter(ta))
Tables.schema(i::TableIter{T,S}) where {T,S} = Tables.Schema(S, coltypes(data(i)))

coltypes(x::AbstractTimeSeries{T,N,D}) where {T,N,D} = (D, (T for _ in 1:size(x, 2))...)

TableTraits.isiterabletable(x::TimeArray) = true
function IteratorInterfaceExtensions.getiterator(ta::TimeArray)
    return Tables.datavaluerows(Tables.columntable(ta))
end
IteratorInterfaceExtensions.isiterable(ta::TimeArray) = true

###############################################################################
#  Constructors
###############################################################################

function TimeSeries.TimeArray(
    x; timestamp::Symbol, timeparser::Base.Callable=identity, unchecked=false
)
    Tables.istable(x) || throw(ArgumentError("TimeArray requires a table as input"))

    sch = Tables.schema(x)
    names = sch.names
    !(timestamp in names) && throw(ArgumentError("time index `$timestamp` not found"))
    names_ = filter(!isequal(timestamp), collect(sch.names))

    cols = Tables.columns(x)
    val = mapreduce(n -> collect(Tables.getcolumn(cols, n)), hcat, names_)
    return TimeArray(
        map(timeparser, Tables.getcolumn(cols, timestamp)),
        val,
        names_,
        x;
        unchecked=unchecked,
    )
end

###############################################################################
#  eachrow/eachcol
###############################################################################
#! format: off
@static if VERSION ≥ v"1.1"
    @doc """
        eachrow(x::TimeArray)
    
    Return a row iterator baked by `Tables.rows`.
    
    # Examples
    
    ```julia
    for row in eachrow(ohlc)
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
#! format: on

end  # TablesIntegration
