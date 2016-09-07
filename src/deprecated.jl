using Base: @deprecate

@deprecate by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) when(ta, period, t)
@deprecate by{T,N}(ta::TimeArray{T,N}, t::String; period::Function=day) when(ta, period, t)

@deprecate to(ta::TimeArray, y::Int, m::Int, d::Int) to(ta, Date(y, m, d))
@deprecate from(ta::TimeArray, y::Int, m::Int, d::Int) from(ta, Date(y, m, d))

@deprecate findall(ta::TimeArray) find(ta)

@deprecate collapse{T,N,D}(ta::TimeArray{T,N,D}, timestamp::Function; period::Function=week) collapse(ta, period, timestamp)

