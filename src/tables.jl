# JuliaData/Tables.jl integration

# const TimeArrayColIter = Tables.EachColumn{<:TimeArray}
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
    S = Tuple(TimeSeries.replace_dupes!([:timestamp; colnames(ta)]))
    TableIter{T,S,N,M}(ta)
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

Tables.istable(::Type{<:AbstractTimeSeries}) = true
Tables.rowaccess(::Type{<:TimeArray}) = true
Tables.rows(ta::TimeArray) = Tables.rows(Tables.columntable(ta))
Tables.columnaccess(::Type{<:TimeArray}) = true
Tables.columns(ta::TimeArray) = TableIter(ta)
Tables.eachcolumn(i::TableIter) = i
Tables.schema(ta::AbstractTimeSeries{T,N,D}) where {T,N,D} = Tables.schema(TableIter(ta))
Tables.schema(i::TableIter{T,S}) where {T,S} = Tables.Schema(S, coltypes(data(i)))

coltypes(x::AbstractTimeSeries{T,N,D}) where {T,N,D} = (D, (T for _ ∈ 1:size(x, 2))...)

function TimeSeries.TimeArray(x; timestamp::Symbol)
    Tables.istable(x) || throw(ArgumentError("TimeArray requires a table input"))

    sch = Tables.schema(x)
    names = sch.names
    (timestamp ∉ names) && throw(ArgumentError("time index `$timestamp` not found"))
    names′ = filter(!isequal(timestamp), collect(sch.names))

    cols = Tables.columns(x)
    val = mapreduce(n -> collect(getproperty(cols, n)), hcat, names′)
    TimeArray(collect(getproperty(cols, timestamp)), val, names′, x)
end

end  # TablesIntegration
