###############################################################################
#  Type
###############################################################################

mutable struct TimeGrid{T,P,L} <: AbstractTimeAxis{T}
    o::T    # start
    p::P    # period
    n::Int  # length, this field is undefined for infinite timegrid.

    function TimeGrid{T,P,:finite}(o, p, n) where {T,P}
        o′ = convert(T, o)
        n′ = convert(Int, n)
        p′ = convert(P, p)

        (n′ < 0) && throw(DomainError(n′))
        new(o′, p′, n′)
    end

    function TimeGrid{T,P,:infinite}(o, p) where {T,P}
        o′ = convert(T, o)
        p′ = convert(P, p)

        new(o′, p′, 0)
    end
end

# TODO: P should be a Dates.FixedPeriod?
# TODO: handle T is `Dates.Time` ?
# TODO: convert type `T` to indicate getindex output type, e.g. Date -> DateTime with Minute period
TimeGrid(o::T, p::P, n::Integer) where {T,P} = TimeGrid{T,P,:finite}(o, p, n)
TimeGrid(o::T, p::P) where {T,P}             = TimeGrid{T,P,:infinite}(o, p)

TimeGrid(tg::TimeGrid{T,P,:infinite}; o = tg.o, p = tg.p) where {T,P} =
    TimeGrid(o, p)
TimeGrid(tg::TimeGrid{T,P,:finite}; o = tg.o, p = tg.p, n = tg.n) where {T,P} =
    TimeGrid(o, p, n)

# TODO: constructor from range


###############################################################################
#  Iterator interfaces
###############################################################################

@generated function Base.iterate(tg::TimeGrid{T,P,L}, s = 1) where {T,P,L}
    quote
        $((L ≡ :infinite) ? :() : :((s > tg.n) && return nothing))
        (tg[s], s + 1)  # FIXME: different state design to reduce * operation?
    end
end

Base.IteratorSize(::Type{TimeGrid{T,P,:infinite}}) where {T,P} = Base.IsInfinite()
Base.IteratorSize(::Type{TimeGrid{T,P,:finite}}) where {T,P}   = Base.HasLength()

Base.IteratorEltype(::Type{<:TimeGrid}) = Base.HasEltype()
Base.eltype(::Type{<:TimeGrid{T}}) where T = T

Base.length(tg::TimeGrid{T,P,:finite}) where {T,P} = tg.n
Base.size(tg::TimeGrid{T,P,:finite}) where{T,P}    = tg.n

###############################################################################
#  Empty TimeGrid
###############################################################################
Base.isempty(tg::TimeGrid{T,P,:finite}) where {T,P} = iszero(tg.n)
Base.isempty(tg::TimeGrid{T,P,:infinite}) where {T,P} = false
Base.isfinite(tg::TimeGrid{T,P,:finite}) where {T,P} = true
Base.isfinite(tg::TimeGrid{T,P,:infinite}) where {T,P} = false

###############################################################################
#  Printing
###############################################################################

function Base.show(io::IO, tg::TimeGrid{T,P,:finite}) where {T,P}
    summary(io, tg)
    if !isempty(tg)
        print(io, "$(tg.o) … $(tg[end]) / $(tg.p) ")
    end
end

function Base.show(io::IO, ::MIME{Symbol("text/plain")}, tg::TimeGrid{T,P,:finite}) where {T,P}
    summary(io, tg)
    if !isempty(tg)
        println(io, ":")
        print(io, " $(tg.o)\n",
                "  ⋮\n",
                " $(tg[end])\n",
                " / $(tg.p)")
    end
end

Base.summary(io::IO, tg::TimeGrid{T,P,:infinite}) where {T,P} =
    print(io, "∞-element ", typeof(tg))

function Base.show(io::IO, ::MIME{Symbol("text/plain")}, tg::TimeGrid{T,P,:infinite}) where {T,P}
    summary(io, tg)
    println(io, ":")
    print(io, " $(tg.o) …\n",
              " / $(tg.p)")
end

###############################################################################
#  Indexing
###############################################################################

# note that Base.size is undefined for this infinite case
Base.lastindex(tg::TimeGrid{T,P,:infinite}) where {T,P} =
    (typemax(DateTime) - tg.o) ÷ Millisecond(tg.p) + 1

@inline function Base.getindex(tg::TimeGrid, i::Real)  # FIXME: is rounding acceptable?
    @boundscheck checkbounds(tg, i)
    ns = Nanosecond(round(Dates.value(Nanosecond(tg.p)) * (i - 1)))
    tg.o + ns
end

@inline function Base.getindex(tg::TimeGrid, i::Integer)
    @boundscheck checkbounds(tg, i)
    tg.o + tg.p * (i - 1)
end

@inline function Base.getindex(tg::TimeGrid, t::TimeType)
    @boundscheck checkbounds(tg, t)
    i = time2idx(tg, t)
    isnothing(i) ? (throw(KeyError(t))) : i
end

const LessOrLessEq       = Union{Base.Fix2{typeof(≤)}, Base.Fix2{typeof(<)}}
const GreaterOrGreaterEq = Union{Base.Fix2{typeof(≥)}, Base.Fix2{typeof(>)}}
const EqOrIsEq           = Union{Base.Fix2{typeof(==)},Base.Fix2{typeof(isequal)}}

Base.findfirst(f::Function, tg::TimeGrid) = findnext(f, tg, 1)

Base.findlast(f::Function, tg::TimeGrid{T,P,:finite}) where {T,P} =
    findprev(f, tg, lastindex(tg))
Base.findlast(f::EqOrIsEq, tg::TimeGrid{T,P,:infinite}) where {T,P} =
    findnext(f, tg, 1)
Base.findlast(f::LessOrLessEq, tg::TimeGrid{T,P,:infinite}) where {T,P} =
    findprev(f, tg, lastindex(tg))
Base.findlast(f::GreaterOrGreaterEq, tg::TimeGrid{T,P,:infinite}) where {T,P} =
    throw(DomainError("infinite iterator. Please use `findprev` instead"))

function Base.findall(f::EqOrIsEq, tg::TimeGrid)
    x = findfirst(f, tg)
    isnothing(x) && return Int[]
    Int[x]
end

function Base.findall(f::LessOrLessEq, tg::TimeGrid)
    x = findlast(f, tg)
    isnothing(x) && return Int[]
    1:x
end

function Base.findall(f::GreaterOrGreaterEq, tg::TimeGrid)
    x = findfirst(f, tg)
    isnothing(x) && return Int[]
    x:lastindex(tg)
end

function Base.findnext(f::EqOrIsEq, tg::TimeGrid{T}, i) where T
    i > lastindex(tg) && return nothing  # mimic behaviour in Base
    x = convert(T, f.x)
    isinbounds(tg, x) || return nothing
    (x < tg[i]) && return nothing
    time2idx(tg, x)
end

function Base.findnext(f::LessOrLessEq, tg::TimeGrid, i)
    i > lastindex(tg) && return nothing  # mimic behaviour in Base
    ifelse(f(tg[i]), i, nothing)
end

@generated function Base.findnext(f::GreaterOrGreaterEq, tg::TimeGrid{T}, i) where T
    func = f.parameters[1]
    op = (func ≡ typeof(>)) ? :(≥) : :(>)
    boundary_cond = Base.haslength(tg) ? :($op(x,tg[end]) && return nothing) : :()
    j = (f.parameters[1] ≡ typeof(>)) ? :(1) : :(Int(!iszero(Δ % p)))

    quote
        i > lastindex(tg) && return nothing  # mimic behaviour in Base
        x = convert(T, f.x)
        $boundary_cond
        f(tg[i]) && return i
        Δ = periodnano(x - tg[i])
        p = periodnano(tg)
        Δ ÷ p + i + $j
    end
end

function Base.findprev(f::EqOrIsEq, tg::TimeGrid{T}, i) where T
    x = convert(T, f.x)
    isinbounds(tg, x) || return nothing
    (x ≤ tg[i]) || return nothing
    time2idx(tg, x)
end

@generated function Base.findprev(f::LessOrLessEq, tg::TimeGrid{T}, i) where T
    func = f.parameters[1]
    cond = (func ≡ typeof(<)) ? :((x ≤ tg.o)) : :((x < tg.o))
    j = (func ≡ typeof(<)) ? :(iszero(Δ % p)) : :(0)

    quote
        isinbounds(tg, i) || throw(BoundsError(tg, i))
        x = convert(T, f.x)
        $cond && return nothing
        Δ = periodnano(x - tg.o)
        p = periodnano(tg)
        min(Δ ÷ p + 1 - $j, i)
    end
end

Base.findprev(f::GreaterOrGreaterEq, tg::TimeGrid, i) = ifelse(f(tg[i]), i, nothing)

# TODO: find function with NNS
# TODO: support find*(in(::Interval), tg)


###############################################################################
#  Relative Time
###############################################################################

Base.getindex(tg::TimeGrid, ::typeof(+), n::Int) =  Nanosecond(tg.p) * n
Base.getindex(tg::TimeGrid, ::typeof(-), n::Int) = -Nanosecond(tg.p) * n

# TODO: test cases
function Base.getindex(tg::TimeGrid, ::typeof(+), p::Period)
    p′ = periodnano(p)
    q = periodnano(tg.p)
    iszero(p′ % q) || throw(KeyError(p))
    p′ ÷ q + 1
end

Base.:+(tg::TimeGrid, i::Real)   = TimeGrid(tg, o = tg.o + Nanosecond(tg.p))
Base.:-(tg::TimeGrid, i::Real)   = TimeGrid(tg, o = tg.o - Nanosecond(tg.p))
Base.:+(tg::TimeGrid, p::Period) = TimeGrid(tg, o = tg.o + p)
Base.:-(tg::TimeGrid, p::Period) = TimeGrid(tg, o = tg.o - p)


###############################################################################
#  SubVector
###############################################################################

Base.view(tg::TimeGrid, r::OrdinalRange{Int,Int}) =
    TimeGrid(tg[first(r)], tg.p * step(r), length(r))

Base.view(tg::TimeGrid, i::ClosedInterval{Int}) =
    TimeGrid(tg[leftendpoint(i)], tg.p, length(i))


###############################################################################
#  Reduction
###############################################################################

function Base.count(i::Interval{:closed,:closed}, tg::TimeGrid)
    x = findfirst(≥(leftendpoint(i)), tg)
    isnothing(x) && return 0
    y = findlast(≤(rightendpoint(i)), tg)
    isnothing(y) && return 0
    abs(y - x) + 1
end


###############################################################################
#  Resampling
###############################################################################

Base.reduce(f, tg::TimeGrid{T,P,:infinite}; kw...) where {T,P} =
    throw(BoundsError("reduce", Inf))
Base.foldl(f, tg::TimeGrid{T,P,:infinite}; kw...) where {T,P} =
    throw(BoundsError("foldl", Inf))
Base.foldr(f, tg::TimeGrid{T,P,:infinite}; kw...) where {T,P} =
    throw(BoundsError("foldr", Inf))
resample(tg::TimeGrid, i::Real) = TimeGrid(tg, p = Nanosecond(tg.p) * i)
resample(tg::TimeGrid, p::Period) = TimeGrid(tg, p = p)


###############################################################################
#  Searching between two point processes
###############################################################################

function Base.findall(tg::TimeGrid{T,P,:finite}, tg′::TimeGrid) where {T,P}
    # FIXME: this is a naive implementation
    A = Vector{Union{Int,Missing}}(undef, tg.n)
    @simd for i ∈ 1:tg.n
        t = tg[i]
        j = findfirst(==(t), tg′)
        A[i] = ifelse(isnothing(j), missing, j)
    end
    A
end

#TODO: NNS


###############################################################################
#  Common vector operations
###############################################################################

Base.resize!(tg::TimeGrid{T,P,:finite}, n::Int) where {T,P} = (tg.n = n; tg)
Base.resize!(tg::TimeGrid{T,P,:infinite}, n::Int) where {T,P} = tg

Base.diff(tg::TimeGrid{T,P,:finite}) where {T,P} = fill(tg.p, tg.n - 1)

###############################################################################
#  Intersect
###############################################################################
function Base.intersect(tg1::TimeGrid, tgs...)
    for tg in tgs
        tg1 = intersect(tg1, tg)
    end
    return tg1
end
# TODO 
# Consider checking if they are equal
function intersect(tg_inf::TimeGrid{T,P,:infinite}, 
                   tg_fin::TimeGrid{T,P,:finite})::TimeGrid{T,P,:finite} where {T,P}
    @assert tg_fin.p == tg_inf.p
    if tg_fin[end] < tg_inf.o
        return TimeGrid(tg_fin.o, tg_fin.p, 0)
    end
    new_o = max(tg_fin.o, tg_inf.o)
    new_n = tg_inf.o > tg_fin.o ? findfirst(isequal(tg_fin[end]), tg_inf) : 
                                  findfirst(isequal(tg_fin[end]), tg_fin)
    return TimeGrid(new_o, tg_fin.p, new_n)
end
intersect(tg_fin::TimeGrid{T,P,:finite}, tg_inf::TimeGrid{T,P,:infinite}) where {T,P} = intersect(tg_inf, tg_fin)
function intersect(tg_inf1::TimeGrid{T,P,:infinite}, tg_inf2::TimeGrid{T,P,:infinite}) where {T,P}
    @assert tg_inf1.p == tg_inf2.p
    new_o = max(tg_inf1.o, tg_inf2.o)
    return TimeGrid(new_o, tg_inf1.p)
end
function intersect(tg_fin1::TimeGrid{T,P,:finite}, tg_fin2::TimeGrid{T,P,:finite}) where {T,P}
    @assert tg_fin1.p == tg_fin2.p
    if (tg_fin2[end] < tg_fin1.o) || (tg_fin1[end] < tg_fin2.o)
        return TimeGrid(tg_fin1.o, tg_fin1.p, 0)
    end
    new_o = max(tg_fin1.o, tg_fin2.o)
    last_idx = min(tg_fin1[end], tg_fin2[end])
    new_n = tg_fin1.o > tg_fin2.o ? findfirst(isequal(last_idx), tg_fin1) : 
                                    findfirst(isequal(last_idx), tg_fin2)
    return TimeGrid(new_o, tg_fin1.p, new_n)
end

###############################################################################
#  Private utils
###############################################################################

isinbounds(tg::TimeGrid{T,P,:infinite}, i::Real) where {T,P} = (1 ≤ i)
isinbounds(tg::TimeGrid{T,P,:finite},   i::Real) where {T,P} = (1 ≤ i ≤ tg.n)
isinbounds(tg::TimeGrid{T,P,:infinite}, t::TimeType) where {T,P} = (tg.o ≤ t)
isinbounds(tg::TimeGrid{T,P,:finite},   t::TimeType) where {T,P} = (tg.o ≤ t ≤ tg[end])

checkbounds(tg::TimeGrid, i::Real) =
    (isinbounds(tg, i) || throw(BoundsError(tg, i)); nothing)
checkbounds(tg::TimeGrid, i::TimeType) =
    (isinbounds(tg, i) || throw(KeyError(i)); nothing)

periodnano(t::Period)    = Dates.value(Nanosecond(t))
periodnano(tg::TimeGrid) = periodnano(tg.p)

function time2idx(tg::TimeGrid, t)
    Δ = periodnano(t - tg.o)
    p = periodnano(tg)
    iszero(Δ % p) || return nothing
    Δ ÷ p + 1
end
