# JuliaData/Tables.jl integration

const TableColumnIter = Tables.EachColumn{<:TimeArray}

Base.getindex(x::TableColumnIter{<:TimeArray}, i::Integer) =
    (i == 1) ? timestamp(x.source) : x.source[colnames(x.source)[i - 1]]
Base.length(x::TableColumnIter{<:TimeArray}) = length(colnames(x.source)) + 1
Base.lastindex(x::TableColumnIter{<:TimeArray}) = length(colnames(x.source)) + 1
Base.propertynames(x::TableColumnIter) = [:timestamp; propertynames(x.source)]

function Base.iterate(x::TableColumnIter{<:TimeArray}, i = 1)
    i > length(x) && return nothing
    values(x[i]), i + 1
end

Tables.istable(::Type{<:AbstractTimeSeries}) = true
Tables.rowaccess(::Type{<:TimeArray}) = false
Tables.columnaccess(::Type{<:TimeArray}) = true
Tables.columns(ta::TimeArray) = Tables.eachcolumn(ta)
Tables.eachcolumn(i::TableColumnIter) = i

Tables.schema(ta::TimeArray{T,N,D}) where {T,N,D} =
    Table.Schema([:timestamp; colnames(ta)], (D, ntuple(x -> T, ndims(ta))...) )


function TimeArray(x; on)
    Tables.istable(x) || throw(ArgumentError("TimeArray requires a table input"))

    sch = Tables.schema(x)
    names = sch.names
    (on ∉ names) && throw(ArgumentError("time index `$on` not found"))
    names′ = [x for x ∈ sch.names if x != on]

    cols = Tables.columns(x)
    val = mapreduce(n -> collect(getproperty(cols, n)), hcat, names′)
    TimeArray(collect(getproperty(cols, on)), val, names′, x)
end
