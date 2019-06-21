###### update ####################

function update(ta::TimeArray{T,N,D}, tstamp::D, val::AbstractArray{T,N}) where {T,N,D}

    if length(ta) == 0
        throw(ArgumentError(
            "updating empty time arrays is not supported, " *
            "please use a scalable approach"))
    elseif tstamp < maximum(timestamp(ta))
        throw(ArgumentError("only appending operations supported"))
    else
        t    = vcat(timestamp(ta), tstamp)
        vals = vcat(values(ta), val)
        uta  = TimeArray(t, vals, colnames(ta), meta(ta))
    end
    uta
end

function update(ta::TimeArray{T,N,D}, tstamp::D, val::T) where {T,N,D}

    if length(ta) == 0
        throw(ArgumentError(
            "updating empty time arrays is not supported, " *
            "please use a scalable approach"))
    elseif tstamp < maximum(timestamp(ta))
        throw(ArgumentError("only appending operations supported"))
    else
        t    = vcat(timestamp(ta), tstamp)
        vals = vcat(values(ta), val)
        uta  = TimeArray(t, vals, colnames(ta), meta(ta))
    end
    uta
end

###### rename, rename! ####################

"""
    rename(ta::TimeArray, colnames::Vector{Symbol})
    rename(ta::TimeArray, colname::Symbol)
    rename(ta::TimeArray, orig => new, ...)
    rename(f::Base.Callable, ta, colnametyp)

Rename the columns of a `TimeArray`.

See also [`rename!`](@ref).

# Arguments
- `colnametyp` is the input type for the function `f`. The valid value is
  `Symbol` or `String`.
"""
function rename(ta::TimeArray, colnames::Vector{Symbol})
    length(colnames) == size(ta, 2) || throw(ArgumentError("Colnames length mismatch"))
    TimeArray(ta, colnames = colnames, unchecked = true)
end

"""
    rename!(ta::TimeArray, colnames::Vector{Symbol})
    rename!(ta::TimeArray, colname::Symbol)
    rename!(ta::TimeArray, orig => new, ...)
    rename!(f::Base.Callable, ta, colnametyp)

In-place rename the columns of a `TimeArray`.

See also [`rename`](@ref).

# Arguments
- `colnametyp` is the input type for the function `f`. The valid value is
  `Symbol` or `String`.
"""
function rename!(ta::TimeArray, colnames::Vector{Symbol})
    length(colnames) == size(ta, 2) ? (_colnames(ta)[:] = colnames) :
    length(colnames) > 0 && throw(ArgumentError("Colnames length mismatch"))
    ta
end

# shared interfaces
for f ∈ [:rename, :rename!]
    @eval begin
        $f(ta::TimeArray, colnames::Symbol) = $f(ta, [colnames])
        $f(ta::TimeArray) = throw(MethodError($f, (ta,)))
        $f(ta::TimeArray, pairs::Pair{Symbol,Symbol}...) =
            $f(ta, _mapcol(colnames(ta), pairs))
        $f(f::Base.Callable, ta::TimeArray, colnametyp::Type{Symbol} = Symbol) =
            $f(ta, map(f, colnames(ta)))
        $f(f::Base.Callable, ta::TimeArray, colnametyp::Type{String}) =
            $f(Symbol ∘ f ∘ string, ta)
    end
end


"""
utility function for `rename` and `rename!`
"""
function _mapcol(col, pairs)
    col′ = copy(col)
    for (key, val) ∈ pairs
        i = findfirst(isequal(key), col)
        if i ≡ nothing  # FIXME: `isnothing(i)` in Julia 1.1
            throw(ArgumentError("Unknown column `$key`"))
        end
        col′[i] = val
    end
    col′
end
