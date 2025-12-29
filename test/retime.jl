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

        @test_throws MethodError TimeSeries._toAggregationMethod(:foo)
    end

    @testset "extrapolation" begin
        @test TimeSeries._toExtrapolationMethod(:fillconstant) ==
            TimeSeries.FillConstant(0.0)
        @test TimeSeries._toExtrapolationMethod(:nearest) == TimeSeries.NearestExtrapolate()
        @test TimeSeries._toExtrapolationMethod(:missing) == TimeSeries.MissingExtrapolate()
        @test TimeSeries._toExtrapolationMethod(:nan) == TimeSeries.NaNExtrapolate()

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

        @testset "empty TimeArray coverage" begin
            ta_empty = TimeArray(Date[], Int[], [:val])
            new_times = Date[]
            ta_new = retime(ta_empty, new_times)
            @test length(ta_new) == 0
            @test isa(ta_new, TimeArray)
        end

        @testset "empty input coverage" begin
            # Non-empty TimeArray, empty new_timestamps
            ta = TimeArray([Date(2020,1,1)], [1], [:val])
            ta_new = retime(ta, Date[])
            @test length(ta_new) == 0
            @test isa(ta_new, TimeArray)

            # Empty TimeArray, non-empty new_timestamps
            ta_empty = TimeArray(Date[], Int[], [:val])
            ta_new2 = retime(ta_empty, [Date(2020,1,1)])
            @test length(ta_new2) == 1
            @test isa(ta_new2, TimeArray)
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
end
