# Abstract types for interpolation, aggregation, and extrapolation methods
abstract type InterpolationMethod end
abstract type AggregationMethod end
abstract type ExtrapolationMethod end

# Interpolation methods
struct Linear <: InterpolationMethod end
struct Previous <: InterpolationMethod end
struct Next <: InterpolationMethod end
struct Nearest <: InterpolationMethod end

# Aggregation methods
struct Mean <: AggregationMethod end
struct Min <: AggregationMethod end
struct Max <: AggregationMethod end
struct Count <: AggregationMethod end
struct Sum <: AggregationMethod end
struct Median <: AggregationMethod end
struct First <: AggregationMethod end
struct Last <: AggregationMethod end
struct AggregationFunction{F<:Function} <: AggregationMethod
    func::F
end

# Extrapolation methods
struct FillConstant{V} <: ExtrapolationMethod
    value::V
end
struct NearestExtrapolate <: ExtrapolationMethod end
struct MissingExtrapolate <: ExtrapolationMethod end
struct NaNExtrapolate <: ExtrapolationMethod end

_toInterpolationMethod(x::Symbol) = _toInterpolationMethod(Val(x))
_toInterpolationMethod(::Val{:linear}) = Linear()
_toInterpolationMethod(::Val{:previous}) = Previous()
_toInterpolationMethod(::Val{:next}) = Next()
_toInterpolationMethod(::Val{:nearest}) = Nearest()
_toInterpolationMethod(x::InterpolationMethod) = x

_toAggregationMethod(x::Symbol) = _toAggregationMethod(Val(x))
_toAggregationMethod(::Val{:mean}) = Mean()
_toAggregationMethod(::Val{:min}) = Min()
_toAggregationMethod(::Val{:max}) = Max()
_toAggregationMethod(::Val{:count}) = Count()
_toAggregationMethod(::Val{:sum}) = Sum()
_toAggregationMethod(::Val{:median}) = Median()
_toAggregationMethod(::Val{:first}) = First()
_toAggregationMethod(::Val{:last}) = Last()
_toAggregationMethof(f::Function) = AggregationFunction(f)
_toAggregationMethod(x::AggregationMethod) = x

_toExtrapolationMethod(x::Symbol) = _toExtrapolationMethod(Val(x))
_toExtrapolationMethod(::Val{:fillconstant}) = FillConstant(0.0)
_toExtrapolationMethod(::Val{:nearest}) = NearestExtrapolate()
_toExtrapolationMethod(::Val{:missing}) = MissingExtrapolate()
_toExtrapolationMethod(::Val{:nan}) = NaNExtrapolate()
_toExtrapolationMethod(x::ExtrapolationMethod) = x

"""
    retime(ta, new_dt::Dates.Period; kwargs...)

Resample or align a `TimeArray` to new timestamps or frequency.
"""
function retime(ta, new_dt::Dates.Period; kwargs...)
    new_timestamps =
        floor(timestamp(ta)[1], new_dt):new_dt:floor(timestamp(ta)[end], new_dt)
    return retime(ta, new_timestamps; kwargs...)
end

function retime(ta, period::Function; kwargs...)
    new_timestamps = map(i -> first(i), _split(timestamp(ta), period))
    return retime(ta, new_timestamps; kwargs...)
end

function retime(
    ta::TimeArray{T,N,D,A},
    new_timestamps::AbstractVector{DN};
    upsample::Union{Symbol,InterpolationMethod}=Previous(),
    downsample::Union{Symbol,Function,AggregationMethod}=Mean(),
    extrapolate::Union{Symbol,ExtrapolationMethod}=NearestExtrapolate(),
    skip_missing::Bool=true,
) where {T,N,D,A,DN}
    upsample = _toInterpolationMethod(upsample)
    downsample = _toAggregationMethod(downsample)
    extrapolate = _toExtrapolationMethod(extrapolate)

    new_values = __allocate_new_values(
        T,
        length(new_timestamps),
        size(ta, 2),
        upsample,
        downsample,
        extrapolate,
        skip_missing,
    )
    old_timestamps = convert(Vector{DN}, timestamp(ta))
    old_values = values(ta)
    @views begin
        for col_i in 1:size(old_values, 2)
            idx = if skip_missing
                findall(x -> !ismissing(x) && !isnan(x), old_values[:, col_i])
            else
                Colon()
            end

            _retime!(
                new_values[:, col_i],
                old_timestamps[idx],
                old_values[idx, col_i],
                new_timestamps,
                upsample,
                downsample,
                extrapolate,
            )
        end
    end
    return TimeArray(new_timestamps, new_values, colnames(ta), meta(ta))
end

function _retime!(
    new_values::AbstractVector{AN},
    old_timestamps::AbstractVector{D},
    old_values::AbstractVector{A},
    new_timestamps::AbstractVector{D},
    upsample::InterpolationMethod,
    downsample::AggregationMethod,
    extrapolate::ExtrapolationMethod,
) where {D,AN,A}
    x = Dates.value.(old_timestamps)
    x_min, x_max = x[1], x[end] # assume that the timestamps are sorted
    x_new = Dates.value.(new_timestamps)

    N = length(x_new)

    @views begin
        # check each interval between i and i+1 if there is no or one sample (upsample), more than one sample (downsample)
        for i in 1:N
            if x_new[i] < x_min || x_new[i] > x_max
                # Handle extrapolation
                new_values[i] = _extrapolate(extrapolate, x_new[i], x, old_values)
            else
                idx = if i < N
                    _get_idx(x, x_new[i], x_new[i + 1])
                else
                    # assume that the last interval is the same length as the second to last one
                    _get_idx(x, x_new[i], x_new[i] + (x_new[i] - x_new[i - 1]))
                end

                if isempty(idx)
                    # No original samples lie between x_new[i] and x_new[i+1] --> Upsampling
                    new_values[i] = _upsample(upsample, x, old_values, x_new[i])
                elseif length(idx) == 1
                    # either we directly hit a sample or there is just one in the interval
                    new_values[i] = old_values[idx[1]]
                else
                    # Multiple samples were found in the interval [x_new[i], x_new[i+1]) --> use the downsample method to get the agglomeration
                    new_values[i] = _downsample(downsample, old_values[idx])
                end
            end
        end
    end
    return nothing
end

function __allocate_new_values(T, N, n, upsample, downsample, extrapolate, skip_missing)
    T = skip_missing ? nonmissingtype(T) : T
    new_type = promote_type(
        T, __get_type(T, upsample), __get_type(T, downsample), __get_type(T, extrapolate)
    )
    return zeros(new_type, N, n)
end

__get_type(::Type{T}, ::InterpolationMethod) where {T} = T
__get_type(::Type{Int}, ::Linear) = Float64 # interpolating integers can result in floats

__get_type(::Type{T}, ::AggregationMethod) where {T} = T
__get_type(::Type{Int}, ::Mean) = Float64 # aggregating integers can result in floats

__get_type(::Type{T}, ::ExtrapolationMethod) where {T} = T
__get_type(::Type{T}, ::MissingExtrapolate) where {T} = Union{T,Missing}

function _get_idx(x::AbstractVector{<:Real}, x_left::Real, x_right::Real)
    idx_left = searchsortedfirst(x, x_left) # greater or equal to x_left
    idx_right = searchsortedlast(x, prevfloat(Float64(x_right))) # less to x_right
    return idx_left:idx_right
end

# Extrapolation dispatch
function _extrapolate(m::FillConstant, t_new, x, y)
    return m.value
end

function _extrapolate(::NearestExtrapolate, t_new, x, y)
    idx = if t_new < x[1]
        1
    else
        length(x)
    end
    return y[idx]
end

function _extrapolate(::MissingExtrapolate, t_new, x, y)
    return missing
end

function _extrapolate(::NaNExtrapolate, t_new, x, y)
    return NaN
end

# Interpolation dispatch
function _upsample(::Linear, x_old, old_values, x)
    idx_next = searchsortedfirst(x_old, x) # greater or equal to x
    idx_prev = searchsortedlast(x_old, x) # less or equal to x
    return y = if idx_prev == idx_next # avoid division by zero
        old_values[idx_prev]
    else
        old_values[idx_prev] +
        (x - x_old[idx_prev]) * (old_values[idx_next] - old_values[idx_prev]) /
        (x_old[idx_next] - x_old[idx_prev])
    end
end

function _upsample(::Previous, x_old, old_values, x)
    idx_prev = searchsortedlast(x_old, x) # less or equal to x
    return old_values[idx_prev]
end

function _upsample(::Next, x_old, old_values, x)
    idx_next = searchsortedfirst(x_old, x) # greater or equal to x
    return old_values[idx_next]
end

function _upsample(::Nearest, x_old, old_values, x)
    idx_next = searchsortedfirst(x_old, x) # greater or equal to x
    idx_prev = searchsortedlast(x_old, x)  # less or equal to x
    y = if idx_prev == idx_next # avoid division by zero
        old_values[idx_prev]
    else
        pos = (x - x_old[idx_prev]) / (x_old[idx_next] - x_old[idx_prev])
        if pos < 0.5
            old_values[idx_prev]
        else
            old_values[idx_next]
        end
    end
    return y
end

# Aggregation dispatch
_downsample(::Mean, values_in_range) = mean(values_in_range)
_downsample(::Min, values_in_range) = minimum(values_in_range)
_downsample(::Max, values_in_range) = maximum(values_in_range)
_downsample(::Count, values_in_range) = count(!ismissing, values_in_range)
_downsample(::Sum, values_in_range) = sum(values_in_range)
_downsample(::Median, values_in_range) = median(values_in_range)
_downsample(::First, values_in_range) = first(values_in_range)
_downsample(::Last, values_in_range) = last(values_in_range)
_downsample(f::AggregationFunction, values_in_range) = f.func(values_in_range)
