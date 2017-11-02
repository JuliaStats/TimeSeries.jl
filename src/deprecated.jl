using Base: @deprecate

@deprecate by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) when(ta, period, t)
@deprecate by{T,N}(ta::TimeArray{T,N}, t::String; period::Function=day) when(ta, period, t)

@deprecate to(ta::TimeArray, y::Int, m::Int, d::Int) to(ta, Date(y, m, d))
@deprecate from(ta::TimeArray, y::Int, m::Int, d::Int) from(ta, Date(y, m, d))

@deprecate findall(ta::TimeArray) find(ta)

@deprecate collapse{T,N,D}(ta::TimeArray{T,N,D}, timestamp::Function; period::Function=week) collapse(ta, period, timestamp)

# since julia 0.6

# deprecate non-dot function due to 0.6 syntactic loop fusion
for f ∈ (:^, :/, :abs, :sign, :sqrt, :cbrt,
         :log, :log2, :log10, :log1p,
         :exp, :exp2, :exp10, :expm1,
         :cos, :sin, :tan, :cosd, :sind, :tand,
         :acos, :asin, :atan, :acosd, :asind, :atand,
         :isnan, :isinf)
    @eval import Base: $f
    @eval @deprecate $f(ta::TimeArray, args...) $f.(ta, args...)
end

for f ∈ (:+, :-, :*, :%,
         :|, :&, :<, :>, :(==), :(!=), :>=, :<=)
    @eval import Base: $f
    @eval @deprecate $f(ta::TimeArray, args...) $f.(ta, args...)
    @eval @deprecate $f(n::Number, ta::TimeArray) $f.(n, ta)
end

# non-dot operators
import Base: $, !, ~

@deprecate ($)(ta1::TimeArray, ta2::TimeArray) xor.(ta1, ta2)
@deprecate ($)(n::Integer, ta::TimeArray) xor.(n, ta)
@deprecate ($)(ta::TimeArray, n::Integer) xor.(ta, n)

@deprecate ~(ta::TimeArray) .~(ta)
@deprecate !(ta::TimeArray) .!(ta)

# apply.jl

@deprecate moving(ta::TimeArray, f, window; padding=false) moving(f, ta, window; padding=padding)
@deprecate upto(ta::TimeArray, f, window; padding=false) upto(f, ta, window; padding=padding)
