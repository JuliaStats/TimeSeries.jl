# Misc. Base and stdlib functions supports

import Base: cumsum, cumprod, sum, all, any
import Statistics: mean, std, var

const _tsmap  = Dict{Any,Dict{Number,Expr}}()  # timestamp map
const _colmap = Dict{Any,Dict{Number,Expr}}()  # colanmes map

"""
To handle :where clause
"""
_get_fname(sig::Expr) =
    (sig.head == :call) ?  sig.args[1] : _get_fname(sig.args[1])

macro _mapbase(sig::Expr, imp::Expr)
    fname = _get_fname(sig)

    # these default values are useful for reduction function
    ts = get(_tsmap, fname, Dict())
    dim1ts = get(ts, 1, :(timestamp(ta)[end]))
    dim2ts = get(ts, 2, :(timestamp(ta)))

    # these default values are useful for reduction function
    col = get(_colmap, fname, Dict())
    dim1col = get(col, 1, :(colnames(ta)))
    dim2col = get(col, 2, :([$(QuoteNode(fname))]))

    fbody = quote
        if dims == 1
            TimeArray($dim1ts, $imp, $dim1col, meta(ta))
        elseif dims == 2
            TimeArray($dim2ts, $imp, $dim2col, meta(ta))
        else
            throw(DimensionMismatch("dims should be 1 or 2"))
        end
    end

    doc = "   $sig"
    fdef = Expr(:function, sig, fbody)

    esc(quote
        $doc
        $fdef
    end)
end

# Cumulative functions
_tsmap[:cumsum] = Dict(1 => :(timestamp(ta)))
_colmap[:cumsum] = Dict(2 => :(colnames(ta)))
@_mapbase cumsum(ta::TimeArray; dims::Integer) cumsum(values(ta), dims = dims)
@_mapbase(cumsum(ta::TimeArray{T,1}, dims::Integer = 1) where{T},
          cumsum(values(ta), dims = dims))

_tsmap[:cumprod] = Dict(1 => :(timestamp(ta)))
_colmap[:cumprod] = Dict(2 => :(colnames(ta)))
@_mapbase cumprod(ta::TimeArray; dims::Integer) cumprod(values(ta), dims = dims)
@_mapbase(cumprod(ta::TimeArray{T,1}; dims::Integer = 1) where {T},
          cumprod(values(ta), dims = dims))

# Reduction functions
@_mapbase sum(ta::TimeArray; dims = 1) sum(values(ta), dims = dims)
@_mapbase all(ta::TimeArray; dims = 1) all(values(ta), dims = dims)
@_mapbase any(ta::TimeArray; dims = 1) any(values(ta), dims = dims)

@_mapbase mean(ta::TimeArray; dims = 1) mean(values(ta), dims = dims)
@_mapbase std(ta::TimeArray; dims = 1, kw...) std(values(ta); dims = dims, kw...)
@_mapbase var(ta::TimeArray; dims = 1, kw...) var(values(ta); dims = dims, kw...)
