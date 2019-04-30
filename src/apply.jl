import Base: +, -
import Base.diff

(+)(ta::TimeArray) = .+ta
(-)(ta::TimeArray) = .-ta

###### lag, lead ################

function lag(ta::TimeArray{T, N}, n::Int=1;
             padding::Bool=false, period::Int=0) where {T, N}

    if period != 0
        @warn("the period kwarg is deprecated, use lag(ta::TimeArray, period::Int) instead")
        n = period
    end

    # TODO: apply `unchecked`
    if padding
        paddedvals = [NaN * ones(n,size(ta, 2)); values(ta)[1:end-n, :]]
        ta = TimeArray(timestamp(ta), paddedvals, colnames(ta), meta(ta))
    else
        ta = TimeArray(timestamp(ta)[1+n:end], values(ta)[1:end-n, :], colnames(ta), meta(ta))
    end

    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta

end  # lag

function lead(ta::TimeArray{T, N}, n::Int=1;
              padding::Bool=false, period::Int=0) where {T, N}

    if period != 0
      @warn("the period kwarg is deprecated, use lead(ta::TimeArray, period::Int) instead")
      n = period
    end

    if padding
        paddedvals = [values(ta)[1+n:end, :]; NaN*ones(n, length(colnames(ta)))]
        ta = TimeArray(timestamp(ta), paddedvals, colnames(ta), meta(ta))
    else
        ta = TimeArray(timestamp(ta)[1:end-n], values(ta)[1+n:end, :], colnames(ta), meta(ta))
    end

    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta

end  # lead

###### diff #####################

function diff(ta::TimeArray, n::Int=1; padding::Bool=false, differences::Int=1)
    cols = colnames(ta)
    for d in 1:differences
        ta = ta .- lag(ta, n, padding=padding)
    end
    colnames(ta)[:] = cols
    return ta
end  # diff

###### percentchange ############

function percentchange(ta::TimeArray, returns::Symbol=:simple;
                       padding::Bool=false, method::AbstractString="")

    if method != ""
        @warn("the method kwarg is deprecated, use percentchange(ta, :methodname) instead")
        returns = Symbol(method)
    end

    cols = colnames(ta)
    ta = returns == :log ? diff(log.(ta), padding=padding) :
         returns == :simple ? expm1.(percentchange(ta, :log, padding=padding)) :
         error("returns must be either :simple or :log")
    colnames(ta)[:] = cols

   return ta

end  # percentchange

###### moving ###################

function moving(f, ta::TimeArray{T, 1}, window::Int;
                padding::Bool = false) where {T}
    tstamps = padding ? timestamp(ta) : timestamp(ta)[window:end]
    vals    = zero(values(ta)[window:end])
    for i=1:length(vals)
        vals[i] = f(values(ta)[i:i+(window-1)])
    end
    padding && (vals = [NaN*ones(window-1); vals])
    TimeArray(tstamps, vals, colnames(ta), meta(ta))
end

function moving(f, ta::TimeArray{T, 2}, window::Int;
                padding::Bool = false) where {T}
    tstamps = padding ? timestamp(ta) : timestamp(ta)[window:end]
    vals    = zero(values(ta)[window:end, :])
    for i=1:size(vals, 1), j=1:size(vals, 2)
        vals[i, j] = f(values(ta)[i:i+(window-1), j])
    end
    padding && (vals = [NaN*fill(1, size(values(ta)[1:(window-1), :])); vals])
    TimeArray(tstamps, vals, colnames(ta), meta(ta))
end

###### upto #####################

function upto(f, ta::TimeArray{T, 1}) where {T}
    vals = zero(values(ta))
    for i=1:length(vals)
        vals[i] = f(values(ta)[1:i])
    end
    TimeArray(timestamp(ta), vals, colnames(ta), meta(ta))
end

function upto(f, ta::TimeArray{T, 2}) where {T}
    vals = zero(values(ta))
    for i=1:size(vals, 1), j=1:size(vals, 2)
        vals[i, j] = f(values(ta)[1:i, j])
    end
    TimeArray(timestamp(ta), vals, colnames(ta), meta(ta))
end

###### basecall #################

basecall(ta::TimeArray, f::Function; cnames=colnames(ta)) =
    TimeArray(timestamp(ta), f(values(ta)), cnames, meta(ta))

###### uniform observations #####

function uniformspaced(ta::TimeArray)
    gap1 = timestamp(ta)[2] - timestamp(ta)[1]
    i, n, is_uniform = 2, length(ta), true
    while is_uniform & (i < n)
        is_uniform = gap1 == (timestamp(ta)[i+1] - timestamp(ta)[i])
        i += 1
    end
    return is_uniform
end  # uniformspaced

function uniformspace(ta::TimeArray{T, N}) where {T, N}
    min_gap = minimum(timestamp(ta)[2:end] - timestamp(ta)[1:end-1])
    newtimestamp = timestamp(ta)[1]:min_gap:timestamp(ta)[end]
    emptyta = TimeArray(collect(newtimestamp), zeros(length(newtimestamp), 0),
                        Symbol[], meta(ta))
    ta = merge(emptyta, ta, :left)
    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta
end  # uniformspace

###### dropnan ####################

dropnan(ta::TimeArray, method::Symbol = :all) =
    method == :all ? ta[findall(reshape(values(any(.!isnan.(ta), dims = 2)), :))] :
    method == :any ? ta[findall(reshape(values(all(.!isnan.(ta), dims = 2)), :))] :
    throw(ArgumentError("dropnan method must be :all or :any"))
