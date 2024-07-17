function retime(ta, new_dt::Dates.Period; kwargs...)
    new_timestamps = timestamp(ta)[1]:new_dt:timestamp(ta)[end]
    return retime(ta, new_timestamps; kwargs...)
end

function retime(ta, period::Function; kwargs...)
    new_timestamps = map(i -> first(timestamp(ta)[i]), _split(timestamp(ta), period))
    return retime(ta, new_timestamps; kwargs...)
end

function retime(
    ta::TimeSeries{T,N,D,A},
    new_timestamps::AbstractVector{DN};
    upsample=:previous,
    downsample::Union{Symbol,Function}=:mean,
    extrapolate::Bool=true,
) where {T,N,D,A,DN}
    new_values = zeros(T, length(new_timestamps), size(values(ta), 2))
    old_timestamps = convert(Vector{DN}, timestamp(ta))
    old_values = values(ta)
    @views begin
        for col_i in 1:size(old_values, 2)
            _retime!(new_values[:, col_i], old_timestamps, old_values[:, col_i], new_timestamps, upsample, downsample, extrapolate)
        end
    end
    return TimeArray(new_timestamps, new_values, colnames(ta), meta(ta))
end

function _retime!(
    new_values::AbstractVector{A},
    old_timestamps::AbstractVector{D},
    old_values::AbstractVector{A},
    new_timestamps::AbstractVector{D},
    upsample,
    downsample,
    extrapolate,
) where {D,A}

    x = Dates.value.(old_timestamps)
    x_min, x_max = extrema(x)
    x_new = Dates.value.(new_timestamps)

    # check each interval between i and i+1 if there is no or one sample (upsample), more than one sample (downsample)
    for i in eachindex(x_new)
    end
    return
end

