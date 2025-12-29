import Base: +, -
import Base.diff

"""
    +(ta::TimeArray)

Element-wise unary plus for a `TimeArray`.
"""
(+)(ta::TimeArray) = .+ta

"""
    -(ta::TimeArray)

Element-wise unary minus for a `TimeArray`.
"""
(-)(ta::TimeArray) = .-ta

###### lag, lead ################

"""
    lag(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0)

Lag a `TimeArray` by `n` periods. Optionally pad with NaN or use the deprecated `period` keyword.
"""
function lag(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0) where {T,N}
    if period != 0
        @warn("the period kwarg is deprecated, use lag(ta::TimeArray, period::Int) instead")
        n = period
    end

    # TODO: apply `unchecked`
    if padding
        paddedvals = [NaN * ones(n, size(ta, 2)); values(ta)[1:(end - n), :]]
        ta = TimeArray(timestamp(ta), paddedvals, colnames(ta), meta(ta))
    else
        ta = TimeArray(
            timestamp(ta)[(1 + n):end], values(ta)[1:(end - n), :], colnames(ta), meta(ta)
        )
    end

    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta
end  # lag

"""
    lead(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0)

Lead a `TimeArray` by `n` periods. Optionally pad with NaN or use the deprecated `period` keyword.
"""
function lead(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0) where {T,N}
    if period != 0
        @warn(
            "the period kwarg is deprecated, use lead(ta::TimeArray, period::Int) instead"
        )
        n = period
    end

    if padding
        paddedvals = [values(ta)[(1 + n):end, :]; NaN * ones(n, length(colnames(ta)))]
        ta = TimeArray(timestamp(ta), paddedvals, colnames(ta), meta(ta))
    else
        ta = TimeArray(
            timestamp(ta)[1:(end - n)], values(ta)[(1 + n):end, :], colnames(ta), meta(ta)
        )
    end

    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta
end  # lead

###### diff #####################

"""
    diff(ta::TimeArray, n::Int=1; padding::Bool=false, differences::Int=1)

Difference a `TimeArray` by `n` periods, optionally multiple times (`differences`).
"""
function diff(ta::TimeArray, n::Int=1; padding::Bool=false, differences::Int=1)
    cols = colnames(ta)
    for d in 1:differences
        ta = ta .- lag(ta, n; padding=padding)
    end
    colnames(ta)[:] = cols
    return ta
end  # diff

###### percentchange ############

"""
    percentchange(ta::TimeArray, returns::Symbol=:simple; padding::Bool=false, method::AbstractString="")

Compute percent change of a `TimeArray`. Use `:simple` or `:log` returns.
"""
function percentchange(
    ta::TimeArray, returns::Symbol=:simple; padding::Bool=false, method::AbstractString=""
)
    if method != ""
        @warn("the method kwarg is deprecated, use percentchange(ta, :methodname) instead")
        returns = Symbol(method)
    end

    cols = colnames(ta)
    ta = if returns == :log
        diff(log.(ta); padding=padding)
    elseif returns == :simple
        expm1.(percentchange(ta, :log; padding=padding))
    else
        throw(ArgumentError("returns must be either :simple or :log"))
    end
    colnames(ta)[:] = cols

    return ta
end  # percentchange

###### moving ###################

# Note: please do not involve any side effects in function `f`
"""
    moving(f, ta::TimeArray{T,1}, w::Integer; padding = false)

Apply user-defined function `f` to a 1D `TimeArray` with window size `w`.

## Example

To calculate the simple moving average of a time series:

```julia
moving(mean, ta, 10)
```
"""
function moving(f, ta::TimeArray{T,1}, window::Integer; padding::Bool=false) where {T}
    ts = padding ? timestamp(ta) : @view(timestamp(ta)[window:end])
    A = values(ta)
    vals = map(i -> f(@view A[i:(i + (window - 1))]), 1:(length(ta) - window + 1))
    padding && (vals = [fill(NaN, window - 1); vals])
    return TimeArray(ta; timestamp=ts, values=vals)
end

"""
    moving(f, ta::TimeArray{T,2}, w::Integer; padding = false, dims = 1, colnames = [...])

## Example

In case of `dims = 2`, the user-defined function `f` will get a 2D `Array` as input.

```julia
moving(ohlc, 10; dims=2, colnames=[:A, ...]) do
    # given that `ohlc` is a 500x4 `TimeArray`,
    # size(A) is (10, 4)
    ...
end
```
"""
function moving(
    f,
    ta::TimeArray{T,2},
    window::Integer;
    padding::Bool=false,
    dims::Integer=1,
    colnames::AbstractVector{Symbol}=_colnames(ta),
) where {T}
    if !(dims ∈ (1, 2))
        throw(ArgumentError("invalid dims $dims"))
    end

    ts = padding ? timestamp(ta) : @view(timestamp(ta)[window:end])
    A = values(ta)

    if dims == 1
        vals = similar(@view(A[window:end, :]))
        for i in 1:size(vals, 1), j in 1:size(vals, 2)
            vals[i, j] = f(@view(A[i:(i + (window - 1)), j]))
        end
    else # case of dims = 2
        vals = mapreduce(i -> f(view(A, (i - window + 1):i, :)), vcat, window:size(A, 1))
        if size(vals, 2) != length(colnames)
            throw(
                DimensionMismatch(
                    "the output dims should match the lenght of columns, " *
                    "please set the keyword argument `colnames` properly.",
                ),
            )
        end
    end

    padding && (vals = [fill(NaN, (window - 1), size(vals, 2)); vals])
    return TimeArray(ta; timestamp=ts, values=vals, colnames=colnames)
end

###### upto #####################

"""
    upto(f, ta::TimeArray{T,1})

Apply function `f` cumulatively up to each index of a 1D `TimeArray`.
"""
function upto(f, ta::TimeArray{T,1}) where {T}
    vals = zero(values(ta))
    for i in 1:length(vals)
        vals[i] = f(values(ta)[1:i])
    end
    return TimeArray(timestamp(ta), vals, colnames(ta), meta(ta))
end

"""
    upto(f, ta::TimeArray{T,2})

Apply function `f` cumulatively up to each index of a 2D `TimeArray` (column-wise).
"""
function upto(f, ta::TimeArray{T,2}) where {T}
    vals = zero(values(ta))
    for i in 1:size(vals, 1), j in 1:size(vals, 2)
        vals[i, j] = f(values(ta)[1:i, j])
    end
    return TimeArray(timestamp(ta), vals, colnames(ta), meta(ta))
end

###### basecall #################

"""
    basecall(ta::TimeArray, f::Function; cnames=colnames(ta))

Apply function `f` to the values of a `TimeArray` and return a new `TimeArray`.
"""
function basecall(ta::TimeArray, f::Function; cnames=colnames(ta))
    return TimeArray(timestamp(ta), f(values(ta)), cnames, meta(ta))
end

###### uniform observations #####

"""
    uniformspaced(ta::TimeArray)

Check if the timestamps of a `TimeArray` are uniformly spaced.
"""
function uniformspaced(ta::TimeArray)
    gap1 = timestamp(ta)[2] - timestamp(ta)[1]
    i, n, is_uniform = 2, length(ta), true
    while is_uniform & (i < n)
        is_uniform = gap1 == (timestamp(ta)[i + 1] - timestamp(ta)[i])
        i += 1
    end
    return is_uniform
end  # uniformspaced

"""
    uniformspace(ta::TimeArray{T,N})

Return a new `TimeArray` with a uniform time grid, filling missing values with NaN.
"""
function uniformspace(ta::TimeArray{T,N}) where {T,N}
    min_gap = minimum(timestamp(ta)[2:end] - timestamp(ta)[1:(end - 1)])
    newtimestamp = timestamp(ta)[1]:min_gap:timestamp(ta)[end]
    emptyta = TimeArray(
        collect(newtimestamp), zeros(length(newtimestamp), 0), Symbol[], meta(ta)
    )
    ta = merge(emptyta, ta; method=:left)
    N == 1 && (ta = ta[colnames(ta)[1]])
    return ta
end  # uniformspace

###### dropnan ####################

"""
    dropnan(ta::TimeArray, method::Symbol=:all)

Drop rows from a `TimeArray` where values are NaN. Use `:all` or `:any` for method.
"""
function dropnan(ta::TimeArray, method::Symbol=:all)
    return if method == :all
        ta[findall(reshape(values(any(.!isnan.(ta); dims=2)), :))]
    elseif method == :any
        ta[findall(reshape(values(all(.!isnan.(ta); dims=2)), :))]
    else
        throw(ArgumentError("dropnan method must be :all or :any"))
    end
end
