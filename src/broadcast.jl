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

@inline function broadcast_c(f, ::Type{TimeArray}, args::Vararg{<:Any, N}) where {N}
    idx, timearrays = _collect_timearrays(args)

    # retain meta if all of TimeArray contain the same one
    meta_ = length(unique(meta.(timearrays))) == 1 ? timearrays[1].meta : Void

    # check column length. all of non-single column should have same length
    cnames = colnames.(timearrays)
    w_ = 1
    for w ∈ length.(cnames)
        if w == 1
            continue
        elseif w_ == 1
            w_ = w
            continue
        elseif w_ != w
            throw(DimensionMismatch(
                "arrays must have the same number of columns, " *
                "or one must be a single column"))
        end
    end

    # contruct new column names
    # TODO: maybe generated function can help for performance
    new_cnames = foldl((x, y) -> x .* "_" .* y, cnames)

    # obtain shared timestamp
    tstamp_idx = noverlaps(timestamp.(timearrays)...)
    tstamp = (timestamp(timearrays[1]))[tstamp_idx[1]]

    # retrieve values that match the Int array matching dates
    arr_vals = collect(values.(getindex.(timearrays, tstamp_idx)))

    # compute output values, broadcast through Array
    arr_args = collect(Any, args)
    arr_args[collect(idx)] = arr_vals
    vals = broadcast(f, arr_args...)

    TimeArray(tstamp, vals, new_cnames, meta_)
end


function _collect_timearrays(args)
    zip(Iterators.filter(x -> isa(x[2], TimeArray), enumerate(args))...)
end


#TODO: support broadcast_getindex
