# JuliaData/Tables.jl integration

const TimeArrayColIter = Tables.EachColumn{<:TimeArray}

source(x::TimeArrayColIter) = getfield(x, :source)

Base.getindex(x::TimeArrayColIter{<:TimeArray}, i::Integer) =
    (i == 1) ? timestamp(source(x)) : values(source(x)[colnames(source(x))[i - 1]])
Base.length(x::TimeArrayColIter{<:TimeArray}) = length(colnames(source(x))) + 1
Base.lastindex(x::TimeArrayColIter{<:TimeArray}) = length(colnames(source(x))) + 1
Base.propertynames(x::TimeArrayColIter) = [:timestamp; propertynames(source(x))]
Base.getproperty(x::TimeArrayColIter, c::Symbol) =
    c == :timestamp ? timestamp(source(x)) : values(getproperty(source(x), c))

function Base.iterate(x::TimeArrayColIter, i = 1)
    i > length(x) && return nothing
    x[i], i + 1
end

Tables.istable(::Type{<:AbstractTimeSeries}) = true
Tables.rowaccess(::Type{<:TimeArray}) = true
Tables.columnaccess(::Type{<:TimeArray}) = true
Tables.columns(ta::TimeArray) = Tables.eachcolumn(ta)
Tables.eachcolumn(i::TimeArrayColIter) = i
Tables.rows(ta::TimeArray) = Tables.rows(Tables.columntable(ta))
Tables.schema(ta::TimeArray{T,N,D}) where {T,N,D} =
    Tables.Schema([:timestamp; colnames(ta)], (D, ntuple(x -> T, size(ta, 2))...) )
Tables.schema(i::TimeArrayColIter) = Tables.schema(source(i))

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
