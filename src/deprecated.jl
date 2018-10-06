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

@deprecate getindex(ta::TimeArray, s::AbstractString) getindex(ta, Symbol(s))

@deprecate getindex(ta::TimeArray, ss::AbstractString...) getindex(ta, Symbol.(ss)...)
