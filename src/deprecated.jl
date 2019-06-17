###############################################################################
#  0.14.0
###############################################################################

@deprecate(
    TimeArray(d::AbstractVector{D}, v::AbstractArray{T,N},
              c::Vector{S}, m::Any = nothing;
              args...) where {T,N,D<:TimeType,S<:AbstractString},
    TimeArray(d, v, Symbol.(c), m; args...)
)

@deprecate(
    TimeArray(d::D, v::AbstractArray{T,N},
              c::Vector{S}, m::Any = nothing;
              args...) where {T,N,D<:TimeType,S<:AbstractString},
    TimeArray(d, v, Symbol.(c), m; args...)
)

@deprecate getindex(ta::TimeArray, s::AbstractString)     getindex(ta, Symbol(s))
@deprecate getindex(ta::TimeArray, ss::AbstractString...) getindex(ta, Symbol.(ss)...)

@deprecate rename(ta::TimeArray, col::String)         rename(ta::TimeArray, Symbol(col))
@deprecate rename(ta::TimeArray, col::Vector{String}) rename(ta, Symbol.(col))

@deprecate(
    merge(ta1::TimeArray{T}, ta2::TimeArray, method::Symbol; kw...) where {T},
    merge(ta1, ta2; method = method, kw...))
