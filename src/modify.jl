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
    return TimeArray(ta; colnames=colnames, unchecked=true)
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
    if length(colnames) == size(ta, 2)
        (_colnames(ta)[:] = colnames)
    else
        length(colnames) > 0 && throw(ArgumentError("Colnames length mismatch"))
    end
    return ta
end

# shared interfaces
for f in [:rename, :rename!]
    @eval begin
        $f(ta::TimeArray, colnames::Symbol) = $f(ta, [colnames])
        $f(ta::TimeArray) = throw(MethodError($f, (ta,)))
        $f(ta::TimeArray, pairs::Pair{Symbol,Symbol}...) =
            $f(ta, _mapcol(colnames(ta), pairs))
        $f(f::Base.Callable, ta::TimeArray, colnametyp::Type{Symbol}=Symbol) =
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
    for (key, val) in pairs
        i = findfirst(isequal(key), col)
        if i ≡ nothing  # FIXME: `isnothing(i)` in Julia 1.1
            throw(ArgumentError("Unknown column `$key`"))
        end
        col′[i] = val
    end
    return col′
end
