# Misc. Base functions

function _autoimport(s::Symbol)
    if isdefined(Base, s)
        :(import Base: $s)
    else
        :()
    end
end

const _tsmap  = Dict{Symbol, Dict{Number, Expr}}()  # timestamp map
const _colmap = Dict{Symbol, Dict{Number, Expr}}()  # colanmes map

macro _mapbase(sig::Expr, imp::Expr)
    fname = sig.args[1]
    import_expr = _autoimport(fname)

    # these default values are useful for reduction function
    ts = get(_tsmap, fname, Dict())
    dim1ts = get(ts, 1, :(ta.timestamp[end]))
    dim2ts = get(ts, 2, :(ta.timestamp))

    # these default values are useful for reduction function
    col = get(_colmap, fname, Dict())
    dim1col = get(col, 1, :(ta.colnames))
    dim2col = get(col, 2, :([string($fname)]))

    fbody = quote
        if dim == 1
            TimeArray($dim1ts, $imp, $dim1col, ta.meta)
        elseif dim == 2
            TimeArray($dim2ts, $imp, $dim2col, ta.meta)
        else
            throw(DimensionMismatch("dim should be 1 or 2"))
        end
    end

    doc = "   $sig"
    fdef = Expr(:function, sig, fbody)

    esc(quote
        $import_expr
        @doc $doc ->
        $fdef
    end)
end

# Cumulative functions
_tsmap[:cumsum] = Dict(1 => :(ta.timestamp))
_colmap[:cumsum] = Dict(2 => :(ta.colnames))
@_mapbase cumsum(ta::TimeArray, dim = 1) cumsum(ta.values, dim)

_tsmap[:cumprod] = Dict(1 => :(ta.timestamp))
_colmap[:cumprod] = Dict(2 => :(ta.colnames))
@_mapbase cumprod(ta::TimeArray, dim = 1) cumprod(ta.values, dim)

# Reduction functions
@_mapbase sum(ta::TimeArray, dim = 1) sum(ta.values, dim)
@_mapbase mean(ta::TimeArray, dim = 1) mean(ta.values, dim)
@_mapbase std(ta::TimeArray, dim = 1; kw...) std(ta.values, dim; kw...)
@_mapbase var(ta::TimeArray, dim = 1; kw...) var(ta.values, dim; kw...)
@_mapbase all(ta::TimeArray, dim = 1) all(ta.values, dim)
@_mapbase any(ta::TimeArray, dim = 1) any(ta.values, dim)
