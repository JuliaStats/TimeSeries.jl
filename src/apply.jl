import Base: +, -
import Base.diff

(+)(ta::TimeArray) = .+ta
(-)(ta::TimeArray) = .-ta

###### lag, lead ################

function lag(ta::TimeArray{T, N}, n::Int=1;
             padding::Bool=false, period::Int=0) where {T, N}

    if period != 0
        warn("the period kwarg is deprecated, use lag(ta::TimeArray, period::Int) instead")
        n = period
    end

    if padding
        paddedvals = [NaN*ones(n, length(ta.colnames)); ta.values[1:end-n, :]]
        ta = TimeArray(ta.timestamp, paddedvals, ta.colnames, ta.meta)
    else
        ta = TimeArray(ta.timestamp[1+n:end], ta.values[1:end-n, :], ta.colnames, ta.meta)
    end

    N == 1 && (ta = ta[ta.colnames[1]])
    return ta

end  # lag

function lead(ta::TimeArray{T, N}, n::Int=1;
              padding::Bool=false, period::Int=0) where {T, N}

    if period != 0
      warn("the period kwarg is deprecated, use lead(ta::TimeArray, period::Int) instead")
      n = period
    end

    if padding
        paddedvals = [ta.values[1+n:end, :]; NaN*ones(n, length(ta.colnames))]
        ta = TimeArray(ta.timestamp, paddedvals, ta.colnames, ta.meta)
    else
        ta = TimeArray(ta.timestamp[1:end-n], ta.values[1+n:end, :], ta.colnames, ta.meta)
    end

    N == 1 && (ta = ta[ta.colnames[1]])
    return ta

end  # lead

###### diff #####################

# TODO: Support higher-order differencing?
function diff(ta::TimeArray; padding::Bool=false)
    cols = ta.colnames
    ta = ta .- lag(ta, padding=padding)
    ta.colnames[:] = cols
    return ta
end  # diff

###### percentchange ############

function percentchange(ta::TimeArray, returns::Symbol=:simple;
                       padding::Bool=false, method::AbstractString="")

    if method != ""
        warn("the method kwarg is deprecated, use percentchange(ta, :methodname) instead")
        returns = Symbol(method)
    end

    cols = ta.colnames
    ta = returns == :log ? diff(log.(ta), padding=padding) :
         returns == :simple ? expm1.(percentchange(ta, :log, padding=padding)) :
         error("returns must be either :simple or :log")
    ta.colnames[:] = cols

   return ta

end  # percentchange

###### moving ###################

function moving(f, ta::TimeArray{T, 1}, window::Int;
                padding::Bool = false) where {T}
    tstamps = padding ? ta.timestamp : ta.timestamp[window:end]
    vals    = zeros(ta.values[window:end])
    for i=1:length(vals)
        vals[i] = f(ta.values[i:i+(window-1)])
    end
    padding && (vals = [NaN*ones(window-1); vals])
    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end

function moving(f, ta::TimeArray{T, 2}, window::Int;
                padding::Bool = false) where {T}
    tstamps = padding ? ta.timestamp : ta.timestamp[window:end]
    vals    = zeros(ta.values[window:end, :])
    for i=1:size(vals, 1), j=1:size(vals, 2)
        vals[i, j] = f(ta.values[i:i+(window-1), j])
    end
    padding && (vals = [NaN*ones(ta.values[1:(window-1), :]); vals])
    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end

###### upto #####################

function upto(f, ta::TimeArray{T, 1}) where {T}
    vals = zeros(ta.values)
    for i=1:length(vals)
        vals[i] = f(ta.values[1:i])
    end
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

function upto(f, ta::TimeArray{T, 2}) where {T}
    vals = zeros(ta.values)
    for i=1:size(vals, 1), j=1:size(vals, 2)
        vals[i, j] = f(ta.values[1:i, j])
    end
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

###### basecall #################

basecall(ta::TimeArray, f::Function; cnames=ta.colnames) =
    TimeArray(ta.timestamp, f(ta.values), cnames, ta.meta)

###### uniform observations #####

function uniformspaced(ta::TimeArray)
    gap1 = ta.timestamp[2] - ta.timestamp[1]
    i, n, is_uniform = 2, length(ta), true
    while is_uniform & (i < n)
        is_uniform = gap1 == (ta.timestamp[i+1] - ta.timestamp[i])
        i += 1
    end
    return is_uniform
end  # uniformspaced

function uniformspace(ta::TimeArray{T, N}) where {T, N}
    min_gap = minimum(ta.timestamp[2:end] - ta.timestamp[1:end-1])
    newtimestamp = ta.timestamp[1]:min_gap:ta.timestamp[end]
    emptyta = TimeArray(collect(newtimestamp), zeros(length(newtimestamp), 0), String[], ta.meta)
    ta = merge(emptyta, ta, :left)
    N == 1 && (ta = ta[ta.colnames[1]])
    return ta
end  # uniformspace

###### dropnan ####################

dropnan(ta::TimeArray, method::Symbol=:all) =
    method == :all ? ta[find(any(.!isnan.(ta.values), 2))] :
    method == :any ? ta[find(all(.!isnan.(ta.values), 2))] :
    error("dropnan method must be :all or :any")
