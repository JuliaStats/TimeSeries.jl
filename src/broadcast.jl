import Base.Broadcast:
    _containertype, promote_containertype, broadcast_c

# make TimeArray as new resulting container type of Base.Broadcast
_containertype(::Type{<:AbstractTimeSeries}) = TimeArray

# From the default rule of promote_containertype:
#     TimeArray, TimeArray -> TimeArray
# And we add following to prevent ambiguous:
#     Array, TimeArray -> TimeArray
promote_containertype(::Type{Array}, ::Type{TimeArray}) = TimeArray
promote_containertype(::Type{TimeArray}, ::Type{Array}) = TimeArray

promote_containertype(::Type{Any}, ::Type{TimeArray}) = TimeArray
promote_containertype(::Type{TimeArray}, ::Type{Any}) = TimeArray


@generated function broadcast_c(f, ::Type{TimeArray}, args::Vararg{Any, N}) where {N}
    idx = Int[]
    colwidth = Expr(:comparison)
    overlaps_expr = :(overlaps())

    for i in 1:N
        if !(args[i] <: TimeArray)
            continue
        end

        # unroll
        push!(idx, i)
        push!(overlaps_expr.args, :(args[$i].timestamp))

        if args[i].parameters[2] == 2  # 2D array
            if !isempty(colwidth.args)
                push!(colwidth.args, :(==))
            end
            push!(colwidth.args, :(length(args[$i].colnames)))
        end
    end

    n = length(idx)

    # retain meta if all of TimeArray contain the same one
    meta_expr = if n == 1
        :(args[$(idx[1])].meta)
    else
        _e = Expr(:comparison, :(args[$(idx[1])].meta))
        for i ∈ 2:n
            push!(_e.args, :(==), :(args[$(idx[i])].meta))
        end
        :($(_e) ? args[$(idx[1])].meta : Void)
    end

    # check column length. all of non-single column should have same length
    # and contruct new column names
    col_check_expr = if length(colwidth.args) > 1  # if we have more than one TimeArray
        quote
            if !($colwidth)
                throw(DimensionMismatch(
                    "arrays must have the same number of columns, " *
                    "or one must be a single column"))
            end
        end
    end

    col_expr = if n == 1
        :(args[$(idx[1])].colnames)
    else
        _e = :(broadcast(_new_cnames))
        append!(_e.args, map(i -> :(args[$i].colnames), idx))
        _e
    end

    # compute output values, broadcast through Array
    broadcast_expr = :(broadcast(f))
    j = 1
    for i ∈ 1:N
        if args[i] <: TimeArray
            if args[i].parameters[2] == 1  # 1D array
                push!(broadcast_expr.args, :(view(args[$i].values, tstamp_idx[$j])))
            else  # 2D array
                push!(broadcast_expr.args, :(view(args[$i].values, tstamp_idx[$j], :)))
            end
            j += 1
        else
            push!(broadcast_expr.args, :(args[$i]))
        end
    end

    quote
        $col_check_expr

        # obtain shared timestamp
        tstamp_idx = $overlaps_expr

        TimeArray(view(args[$(idx[1])].timestamp, tstamp_idx[1]),
                  $broadcast_expr,
                  $col_expr,
                  $meta_expr)
    end
end


@generated function _new_cnames(args::Vararg{String, N}) where N
    expr = :(string(args[1]))
    for i ∈ 2:N
        push!(expr.args, "_", :(args[$i]))
    end
    expr
end


#TODO: support broadcast_getindex
