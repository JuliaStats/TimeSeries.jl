using Test
using MarketData
using TimeSeries
using Dates
using Statistics

@testset "retime" begin
    @testset "interpolation" begin
        @test TimeSeries._toInterpolationMethod(:linear) == TimeSeries.Linear()
        @test TimeSeries._toInterpolationMethod(:nearest) == TimeSeries.Nearest()
        @test TimeSeries._toInterpolationMethod(:previous) == TimeSeries.Previous()
        @test TimeSeries._toInterpolationMethod(:next) == TimeSeries.Next()

        @test_throws MethodError TimeSeries._toInterpolationMethod(:foo)
    end

    @testset "aggregation" begin
        @test TimeSeries._toAggregationMethod(:mean) == TimeSeries.Mean()
        @test TimeSeries._toAggregationMethod(:min) == TimeSeries.Min()
        @test TimeSeries._toAggregationMethod(:max) == TimeSeries.Max()
        @test TimeSeries._toAggregationMethod(:count) == TimeSeries.Count()
        @test TimeSeries._toAggregationMethod(:sum) == TimeSeries.Sum()
        @test TimeSeries._toAggregationMethod(:median) == TimeSeries.Median()
        @test TimeSeries._toAggregationMethod(:first) == TimeSeries.First()
        @test TimeSeries._toAggregationMethod(:last) == TimeSeries.Last()

        # Test function conversion to AggregationFunction
        custom_func = x -> sum(x) / length(x)
        agg_method = TimeSeries._toAggregationMethod(custom_func)
        @test agg_method isa TimeSeries.AggregationFunction
        @test agg_method.func === custom_func

        @test_throws MethodError TimeSeries._toAggregationMethod(:foo)
    end

    @testset "extrapolation" begin
        @test TimeSeries._toExtrapolationMethod(:fillconstant) ==
            TimeSeries.FillConstant(0.0)
        @test TimeSeries._toExtrapolationMethod(:nearest) == TimeSeries.NearestExtrapolate()
        @test TimeSeries._toExtrapolationMethod(:missing) == TimeSeries.MissingExtrapolate()
        @test TimeSeries._toExtrapolationMethod(:nan) == TimeSeries.NaNExtrapolate()

        # Test custom FillConstant values
        @test TimeSeries.FillConstant(42.0).value == 42.0
        @test TimeSeries.FillConstant(-1).value == -1

        @test_throws MethodError TimeSeries._toExtrapolationMethod(:foo)
    end

    @testset "single column" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        funcs = [mean, sum, minimum, maximum, last]
        downsamples = [
            TimeSeries.Mean(),
            TimeSeries.Sum(),
            TimeSeries.Min(),
            TimeSeries.Max(),
            TimeSeries.Last(),
        ]
        @testset for (func, downsample) in zip(funcs, downsamples)
            cl_new = retime(cl, new_timestamps; upsample=TimeSeries.Linear(), downsample)

            @test timestamp(cl_new) == new_timestamps

            # extrapolation
            @test values(cl_new[1, :Close]) == values(cl[1, :Close])

            # aggregation
            idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
            @test func(values(cl[:Close][idx])) == values(cl_new[:Close][2])[1]
        end

        # test using Symbols
        downsamples = [:mean, :sum, :min, :max, :last]
        @testset for (func, downsample) in zip(funcs, downsamples)
            cl_new = retime(cl, new_timestamps; upsample=TimeSeries.Linear(), downsample)

            @test timestamp(cl_new) == new_timestamps

            # extrapolation
            @test values(cl_new[1, :Close]) == values(cl[1, :Close])

            # aggregation
            idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
            @test func(values(cl[:Close][idx])) == values(cl_new[:Close][2])[1]
        end
    end

    @testset "single column interpolation" begin
        new_timestamps = collect(Dates.DateTime(2000):Dates.Hour(1):Dates.DateTime(2001))

        upsamples = [
            TimeSeries.Linear(),
            TimeSeries.Previous(),
            TimeSeries.Next(),
            TimeSeries.Nearest(),
        ]
        @testset for upsample in upsamples
            cl_new = retime(cl, new_timestamps; upsample)

            @test timestamp(cl_new) == new_timestamps

            # TODO: real tests
        end

        # test using Symbols
        upsamples = [:linear, :previous, :next, :nearest]
        @testset for upsample in upsamples
            cl_new = retime(cl, new_timestamps; upsample)

            @test timestamp(cl_new) == new_timestamps

            # TODO: real tests
        end
    end

    @testset "single column extrapolate" begin
        new_timestamps = collect(Dates.DateTime(2000):Dates.Hour(1):Dates.DateTime(2001))

        cl_new = retime(cl, new_timestamps; extrapolate=TimeSeries.FillConstant(0.0))
        @test timestamp(cl_new) == new_timestamps
        @test values(cl_new[:Close][1])[1] == 0.0

        # Test custom fill value
        cl_new = retime(cl, new_timestamps; extrapolate=TimeSeries.FillConstant(99.9))
        @test timestamp(cl_new) == new_timestamps
        @test values(cl_new[:Close][1])[1] == 99.9

        cl_new = retime(cl, new_timestamps; extrapolate=TimeSeries.NearestExtrapolate())
        @test timestamp(cl_new) == new_timestamps
        @test values(cl_new[:Close][1])[1] == values(cl[:Close][1])[1]

        cl_new = retime(cl, new_timestamps; extrapolate=TimeSeries.MissingExtrapolate())
        @test timestamp(cl_new) == new_timestamps
        @test all(ismissing.(values(cl_new[:Close][1])))

        cl_new = retime(cl, new_timestamps; extrapolate=TimeSeries.NaNExtrapolate())
        @test timestamp(cl_new) == new_timestamps
        @test all(isnan.(values(cl_new[:Close][1])))
    end

    @testset "multi column" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        funcs = [mean, sum, minimum, maximum, last]
        downsamples = [
            TimeSeries.Mean(),
            TimeSeries.Sum(),
            TimeSeries.Min(),
            TimeSeries.Max(),
            TimeSeries.Last(),
        ]
        @testset for (func, downsample) in zip(funcs, downsamples)
            ohlc_new = retime(
                ohlc,
                new_timestamps;
                upsample=TimeSeries.Linear(),
                downsample=TimeSeries.Mean(),
            )

            @test timestamp(ohlc_new) == new_timestamps

            # extrapolation
            @test values(ohlc_new[1]) == values(ohlc_new[1])

            idx = new_timestamps[2] .<= timestamp(ohlc) .< new_timestamps[3]
            @test mean(values(ohlc[idx]); dims=1) == values(ohlc_new[2])
        end
    end

    @testset "multi column interpolation" begin
        new_timestamps = collect(Dates.DateTime(2000):Dates.Hour(1):Dates.DateTime(2001))

        upsamples = [
            TimeSeries.Linear(),
            TimeSeries.Previous(),
            TimeSeries.Next(),
            TimeSeries.Nearest(),
        ]
        @testset for upsample in upsamples
            ohlc_new = retime(ohlc, new_timestamps; upsample)

            @test timestamp(ohlc_new) == new_timestamps

            # TODO: real tests
        end
    end

    @testset "multi column extrapolate" begin
        new_timestamps = collect(Dates.DateTime(2000):Dates.Hour(1):Dates.DateTime(2001))

        ohlc_new = retime(ohlc, new_timestamps; extrapolate=TimeSeries.FillConstant(0.0))
        @test timestamp(ohlc_new) == new_timestamps
        @test values(ohlc_new[1]) == zeros(1, 4)

        ohlc_new = retime(ohlc, new_timestamps; extrapolate=TimeSeries.NearestExtrapolate())
        @test timestamp(ohlc_new) == new_timestamps
        @test values(ohlc_new[1]) == values(ohlc[1])

        ohlc_new = retime(ohlc, new_timestamps; extrapolate=TimeSeries.MissingExtrapolate())
        @test timestamp(ohlc_new) == new_timestamps
        @test all(ismissing.(values(ohlc_new[1])))

        ohlc_new = retime(ohlc, new_timestamps; extrapolate=TimeSeries.NaNExtrapolate())
        @test timestamp(ohlc_new) == new_timestamps
        @test all(isnan.(values(ohlc_new[1])))
    end

    @testset "single column with missing" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))
        # corrupt some values
        cl_missing = TimeArray(
            timestamp(cl),
            let vals = convert(Vector{Union{Float64,Missing}}, copy(values(cl)))
                vals[rand(1:length(vals), 100)] .= missing
                vals
            end,
            colnames(cl),
        )

        cl_new = retime(
            cl_missing,
            new_timestamps;
            upsample=:linear,
            downsample=:mean,
            skip_missing=false,
        )

        cl_new = retime(
            cl_missing,
            new_timestamps;
            upsample=:linear,
            downsample=:mean,
            skip_missing=true,
        )
        @test !any(ismissing.(values(cl_new)))
    end

    @testset "single column with NaN" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))
        # corrupt some values
        cl_missing = TimeArray(
            timestamp(cl),
            let vals = copy(values(cl))
                vals[rand(1:length(vals), 100)] .= NaN
                vals
            end,
            colnames(cl),
        )

        cl_new = retime(
            cl_missing,
            new_timestamps;
            upsample=:linear,
            downsample=:mean,
            skip_missing=false,
        )

        cl_new = retime(
            cl_missing,
            new_timestamps;
            upsample=:linear,
            downsample=:mean,
            skip_missing=true,
        )
        @test !any(isnan.(values(cl_new)))
    end

    @testset "Aggregate integers with :mean" begin
        ta = TimeArray(
            [
                DateTime(2025, 1, 1, 8, 0),
                DateTime(2025, 1, 2, 2, 0),
                DateTime(2025, 1, 3, 9, 0),
            ],
            [1, 2, 3],
        )

        ta_new = retime(ta, Day(1))
    end

    @testset "Interpolate integers with :linear" begin
        ta = TimeArray(
            [
                DateTime(2025, 1, 1, 8, 0),
                DateTime(2025, 1, 2, 2, 0),
                DateTime(2025, 1, 3, 9, 0),
            ],
            [1, 2, 3],
        )

        ta_new = retime(ta, Hour(1); upsample=:linear)
    end

    @testset "AggregationFunction with custom function" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        # Test with custom function: weighted average favouring first value
        custom_agg = x -> 0.7 * first(x) + 0.3 * last(x)
        cl_new = retime(cl, new_timestamps; downsample=custom_agg)

        @test timestamp(cl_new) == new_timestamps

        # Verify custom function is applied
        idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
        cl_values = values(cl[:Close][idx])
        expected = 0.7 * first(cl_values) + 0.3 * last(cl_values)
        @test expected == values(cl_new[:Close][2])[1]

        # Test with standard deviation function
        cl_new_std = retime(cl, new_timestamps; downsample=std)
        @test timestamp(cl_new_std) == new_timestamps

        # Test with custom function on multi-column
        ohlc_new = retime(ohlc, new_timestamps; downsample=x -> median(x))
        @test timestamp(ohlc_new) == new_timestamps
    end

    @testset "Count aggregation" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        cl_new = retime(cl, new_timestamps; downsample=TimeSeries.Count())
        @test timestamp(cl_new) == new_timestamps

        # Verify count is correct
        idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
        expected_count = count(!ismissing, values(cl[:Close][idx]))
        @test expected_count == values(cl_new[:Close][2])[1]

        # Test count with symbol
        cl_new_sym = retime(cl, new_timestamps; downsample=:count)
        @test values(cl_new) == values(cl_new_sym)
    end

    @testset "First and Last aggregation" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        cl_first = retime(cl, new_timestamps; downsample=TimeSeries.First())
        cl_last = retime(cl, new_timestamps; downsample=TimeSeries.Last())

        @test timestamp(cl_first) == new_timestamps
        @test timestamp(cl_last) == new_timestamps

        # Verify first and last are correct
        idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
        @test first(values(cl[:Close][idx])) == values(cl_first[:Close][2])[1]
        @test last(values(cl[:Close][idx])) == values(cl_last[:Close][2])[1]
    end

    @testset "Median aggregation" begin
        new_timestamps = collect(Dates.Date(2000):Dates.Week(1):Dates.Date(2001))

        cl_new = retime(cl, new_timestamps; downsample=:median)
        @test timestamp(cl_new) == new_timestamps

        # Verify median is correct
        idx = new_timestamps[2] .<= timestamp(cl) .< new_timestamps[3]
        @test median(values(cl[:Close][idx])) == values(cl_new[:Close][2])[1]
    end
end
