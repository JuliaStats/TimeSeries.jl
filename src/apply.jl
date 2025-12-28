import Base: +, -
import Base.diff

"""
    +(ta::TimeArray)

Unary plus operator for `TimeArray`.

Returns a broadcasted copy with the unary plus operator applied elementwise.
"""
(+)(ta::TimeArray) = .+ta

"""
    -(ta::TimeArray)

Unary minus operator for `TimeArray`.

Returns a broadcasted copy with elementwise negation applied to all values.
"""
(-)(ta::TimeArray) = .-ta

###### lag, lead ################

"""
    lag(ta::TimeArray, n::Int=1; padding::Bool=false)

Shift values backward by `n` periods, removing the first `n` rows.

# Arguments

  - `n::Int`: Number of periods to lag (default: 1)
  - `padding::Bool`: If `true`, pad with `NaN` to maintain length (default: `false`)

Note: The deprecated `period` keyword argument is also accepted but should not be used.

# Examples

```julia
lag(ta)           # Lag by 1 period
lag(ta, 5)        # Lag by 5 periods
lag(ta, padding=true)  # Lag with NaN padding
```
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
    lead(ta::TimeArray, n::Int=1; padding::Bool=false)

Shift values forward by `n` periods, removing the last `n` rows.

# Arguments

  - `n::Int`: Number of periods to lead (default: 1)
  - `padding::Bool`: If `true`, pad with `NaN` to maintain length (default: `false`)

Note: The deprecated `period` keyword argument is also accepted but should not be used.

# Examples

```julia
lead(ta)           # Lead by 1 period
lead(ta, 5)        # Lead by 5 periods
lead(ta, padding=true)  # Lead with NaN padding
```
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

Calculate the `n`-period difference of a `TimeArray`.

This is a `TimeArray` specialization of `Base.diff`.

# Arguments

  - `n::Int`: Number of periods for differencing (default: 1)
  - `padding::Bool`: If `true`, pad with `NaN` to maintain length (default: `false`)
  - `differences::Int`: Number of times to apply differencing (default: 1)

# Examples

```julia
diff(ta)              # First difference
diff(ta, 2)           # 2-period difference
diff(ta, differences=2)  # Second-order difference
```
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
    percentchange(ta::TimeArray, returns::Symbol=:simple; padding::Bool=false)

Calculate percentage change between consecutive periods.

# Arguments

  - `returns::Symbol`: Type of returns calculation - `:simple` or `:log` (default: `:simple`)
  - `padding::Bool`: If `true`, pad with `NaN` to maintain length (default: `false`)

# Examples

```julia
percentchange(ta)           # Simple returns
percentchange(ta, :log)     # Log returns
percentchange(ta, padding=true)  # With NaN padding
```
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

Apply user-defined function `f` to a 2D `TimeArray` with window size `w`.

# Arguments

  - `f`: Function to apply to each window
  - `ta::TimeArray{T,2}`: 2D time array
  - `w::Integer`: Window size
  - `padding::Bool`: If `true`, pad with `NaN` to maintain length (default: `false`)
  - `dims::Integer`: Dimension to apply function - `1` for column-wise, `2` for row-wise (default: 1)
  - `colnames::Vector{Symbol}`: Column names for result (default: original column names)

# Examples

```julia
moving(mean, ta, 10)  # 10-period moving average

# For dims=2, function receives a 2D window
moving(ta, 10; dims=2) do window
    # window is a 10×ncol matrix
    sum(window)
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
    upto(f, ta::TimeArray)

Apply function `f` cumulatively from the start up to each row.

# Examples

```julia
upto(sum, ta)   # Cumulative sum
upto(mean, ta)  # Expanding mean
```
"""
function upto(f, ta::TimeArray{T,1}) where {T}
    vals = zero(values(ta))
    for i in 1:length(vals)
        vals[i] = f(values(ta)[1:i])
    end
    return TimeArray(timestamp(ta), vals, colnames(ta), meta(ta))
end

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

Apply a function `f` to the values array and return a new `TimeArray`.

# Arguments

  - `f::Function`: Function to apply to the values array
  - `cnames`: Column names for the result (default: original column names)

# Examples

```julia
basecall(ta, transpose)  # Transpose the values
basecall(ta, sort; cnames=[:Sorted])  # Sort values
```
"""
function basecall(ta::TimeArray, f::Function; cnames=colnames(ta))
    return TimeArray(timestamp(ta), f(values(ta)), cnames, meta(ta))
end

###### uniform observations #####

"""
    uniformspaced(ta::TimeArray)

Check if timestamps in a `TimeArray` are uniformly spaced.

Returns `true` if all consecutive timestamp differences are equal, `false` otherwise.
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
    uniformspace(ta::TimeArray)

Convert a `TimeArray` to uniform spacing using the minimum gap between timestamps.

Missing timestamps are filled with rows containing zeros.
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

Remove rows containing `NaN` values from a `TimeArray`.

# Arguments

  - `method::Symbol`: Removal strategy - `:all` removes rows where all values are `NaN`, `:any` removes rows with any `NaN` (default: `:all`)

# Examples

```julia
dropnan(ta)        # Remove rows where all values are NaN
dropnan(ta, :any)  # Remove rows with any NaN
```
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
