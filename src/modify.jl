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

###### rename ####################

function rename(ta::TimeArray, colnames::Vector{Symbol})
    length(colnames) == size(ta, 2) || throw(DimensionMismatch("Colnames length mismatch"))
    TimeArray(ta, colnames = colnames, unchecked = true)
end

rename(ta::TimeArray, colnames::Symbol) = rename(ta, [colnames])

function rename(ta::TimeArray, args::Pair{Symbol,Symbol}...)
    d_colnames = Dict{Symbol,Symbol}(args...)
    _colnames = copy(colnames(ta))
    for (i, colname) in enumerate(_colnames)
        if colname in keys(d_colnames)
            _colnames[i] = d_colnames[colname]
        end
    end
    rename(ta, _colnames)
end

function rename(f::Base.Callable, ta::TimeArray, colnametyp::Type{Symbol} = Symbol)
    _colnames = copy(colnames(ta))
    for (i, colname) in enumerate(_colnames)
        _colnames[i] = f(colname)
    end
    rename(ta, _colnames)
end

function rename(f::Base.Callable, ta::TimeArray, colnametyp::Type{String})
    f = Symbol ∘ f ∘ string
    rename(f, ta)
end
