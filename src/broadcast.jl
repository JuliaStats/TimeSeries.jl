using Base.Broadcast: Broadcasted, DefaultArrayStyle

abstract type AbstractTimeSeriesStyle{N} <: Broadcast.AbstractArrayStyle{N} end

struct TimeArrayStyle{N} <: AbstractTimeSeriesStyle{N} end
TimeArrayStyle(::Val{N}) where N = TimeArrayStyle{N}()
TimeArrayStyle{M}(::Val{N}) where {N,M} = TimeArrayStyle{N}()

# Determin the output type
Base.BroadcastStyle(::Type{<:TimeArray{T,N}}) where {T,N} = TimeArrayStyle{N}()

Base.broadcastable(x::AbstractTimeSeries) = x

Base.Broadcast.instantiate(bc::Broadcasted{<:TimeArrayStyle}) =
    # skip the default axes checking
    Broadcast.flatten(bc)


function Base.copy(bc′::Broadcasted{<:TimeArrayStyle})
    tas = find_ta(bc′)

    check_column_lens(tas)

    n = length(tas)
    col′ = (n == 1) ? colnames(tas[1]) : _new_cnames.(colnames.(tas)...)
    meta′ = (n == 1) ? meta(tas[1]) : (allequal(meta.(tas)) ? meta(tas[1]) : nothing)

    # obtain shared timestamp
    tstamp_idx = overlap(timestamp.(tas)...)

    # replace TimeArray objects into Array in the Broadcasted arguments
    j = 0
    args = Any[]
    for (i, arg) ∈ enumerate(bc′.args)
        x = if arg isa TimeArray
            j += 1
            if typeof(arg).parameters[2] == 1  # 1D array
                view(values(arg), tstamp_idx[j])
            else
                view(values(arg), tstamp_idx[j], :)
            end
        else
            arg
        end
        push!(args, x)
    end

    TimeArray(view(timestamp(tas[1]), tstamp_idx[1]),
              broadcast(bc′.f, args...),
              col′,
              meta′)
end

@inline function check_column_lens(tas::Tuple)
    length(tas) <= 1 && return

    # if we have more than one TimeArray
    lens = Set(i for i ∈ map(ta -> length(colnames(ta)), tas) if i ≠ 1)
    length(lens) > 1 && throw(
        DimensionMismatch(
            "TimeArrays must have the same number of columns, " *
            "or one must be a single column"))
end

"""
find all TimeArray in the Broadcasted args and return a tuple of them.
"""
function find_ta(bc)
    ret = tuple()
    for i ∈ bc.args
        if i isa TimeArray
            ret = tuple(ret..., i)
        end
    end
    ret
end

@generated function _new_cnames(args::Vararg{Symbol, N}) where N
    expr = :(Symbol(args[1]))
    for i ∈ 2:N
        push!(expr.args, "_", :(args[$i]))
    end
    expr
end
