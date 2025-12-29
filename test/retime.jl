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
    end

    @testset "single column interpolation" begin
        # Create simple test data with known values for verification
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 2, 0), DateTime(2020, 1, 1, 4, 0)]
        test_values = [10.0, 20.0, 30.0]
        test_ta = TimeArray(test_timestamps, test_values, [:Value])
        
        # Test Linear interpolation
        new_ts = [DateTime(2020, 1, 1, 1, 0), DateTime(2020, 1, 1, 3, 0)]
        result = retime(test_ta, new_ts; upsample=TimeSeries.Linear())
        @test values(result)[1] ≈ 15.0  # midpoint between 10 and 20
        @test values(result)[2] ≈ 25.0  # midpoint between 20 and 30
        
        # Test Previous interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Previous())
        @test values(result)[1] == 10.0  # uses previous value
        @test values(result)[2] == 20.0  # uses previous value
        
        # Test Next interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Next())
        @test values(result)[1] == 20.0  # uses next value
        @test values(result)[2] == 30.0  # uses next value
        
        # Test Nearest interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Nearest())
        @test values(result)[1] == 10.0  # closer to 10 than 20
        @test values(result)[2] == 20.0  # closer to 20 than 30
        
        # Test with exact timestamp match
        exact_ts = [DateTime(2020, 1, 1, 2, 0)]
        result = retime(test_ta, exact_ts; upsample=TimeSeries.Linear())
        @test values(result)[1] == 20.0  # exact match
        
        # Test using Symbols
        result = retime(test_ta, new_ts; upsample=:linear)
        @test values(result)[1] ≈ 15.0
        
        result = retime(test_ta, new_ts; upsample=:previous)
        @test values(result)[1] == 10.0
        
        result = retime(test_ta, new_ts; upsample=:next)
        @test values(result)[1] == 20.0
        
        result = retime(test_ta, new_ts; upsample=:nearest)
        @test values(result)[1] == 10.0
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
        # Create simple multi-column test data
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 2, 0), DateTime(2020, 1, 1, 4, 0)]
        test_values = [10.0 100.0; 20.0 200.0; 30.0 300.0]
        test_ta = TimeArray(test_timestamps, test_values, [:A, :B])
        
        new_ts = [DateTime(2020, 1, 1, 1, 0), DateTime(2020, 1, 1, 3, 0)]
        
        # Test Linear interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Linear())
        @test values(result)[1, 1] ≈ 15.0
        @test values(result)[1, 2] ≈ 150.0
        @test values(result)[2, 1] ≈ 25.0
        @test values(result)[2, 2] ≈ 250.0
        
        # Test Previous interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Previous())
        @test values(result)[1, 1] == 10.0
        @test values(result)[1, 2] == 100.0
        
        # Test Next interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Next())
        @test values(result)[1, 1] == 20.0
        @test values(result)[1, 2] == 200.0
        
        # Test Nearest interpolation
        result = retime(test_ta, new_ts; upsample=TimeSeries.Nearest())
        @test values(result)[1, 1] == 10

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

    @testset "Custom aggregation function" begin
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 1, 0), 
                          DateTime(2020, 1, 1, 2, 0), DateTime(2020, 1, 1, 3, 0)]
        test_values = [1.0, 2.0, 3.0, 4.0]
        test_ta = TimeArray(test_timestamps, test_values, [:Value])
        
        # Test custom function (e.g., product)
        custom_func = x -> prod(x)
        new_ts = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 2, 0)]
        result = retime(test_ta, new_ts; downsample=custom_func)
        
        # First interval should contain values 1.0 and 2.0, product = 2.0
        @test values(result)[1] == 2.0
        # Second interval should contain values 3.0 and 4.0, product = 12.0
        @test values(result)[2] == 12.0
    end

    @testset "Edge cases" begin
        # Single data point
        single_ta = TimeArray([DateTime(2020, 1, 1)], [42.0], [:Value])
        new_ts = [DateTime(2020, 1, 1)]
        result = retime(single_ta, new_ts)
        @test values(result)[1] == 42.0
        
        # Exact timestamp matches
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 2, 0)]
        test_values = [10.0, 20.0]
        test_ta = TimeArray(test_timestamps, test_values, [:Value])
        result = retime(test_ta, test_timestamps)
        @test values(result) == test_values
        
        # Last timestamp handling (tests the i == N branch)
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 1, 0), 
                          DateTime(2020, 1, 1, 2, 0)]
        test_values = [10.0, 20.0, 30.0]
        test_ta = TimeArray(test_timestamps, test_values, [:Value])
        new_ts = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 1, 0), 
                 DateTime(2020, 1, 1, 2, 0)]
        result = retime(test_ta, new_ts; downsample=TimeSeries.Mean())
        @test length(values(result)) == 3
    end

    @testset "Period-based resampling" begin
        test_timestamps = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 1, 30), 
                          DateTime(2020, 1, 1, 3, 0)]
        test_values = [10.0, 20.0, 30.0]
        test_ta = TimeArray(test_timestamps, test_values, [:Value])
        
        # Test with Period
        result = retime(test_ta, Hour(1))
        @test length(timestamp(result)) > 0
        @test timestamp(result)[1] == DateTime(2020, 1, 1, 0, 0)
        
        # Verify it produces same result as explicit timestamps
        explicit_ts = collect(DateTime(2020, 1, 1, 0, 0):Hour(1):DateTime(2020, 1, 1, 3, 0))
        result_explicit = retime(test_ta, explicit_ts)
        @test timestamp(result) == timestamp(result_explicit)
    end

    @testset "Type promotion" begin
        # Integer with Linear should promote to Float64
        int_ta = TimeArray([DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 2, 0)], 
                          [10, 20], [:Value])
        new_ts = [DateTime(2020, 1, 1, 1, 0)]
        result = retime(int_ta, new_ts; upsample=:linear)
        @test eltype(values(result)) == Float64
        @test values(result)[1] == 15.0
        
        # Integer with Mean should promote to Float64
        int_ta2 = TimeArray([DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 0, 30), 
                            DateTime(2020, 1, 1, 1, 0)], [10, 15, 20], [:Value])
        new_ts2 = [DateTime(2020, 1, 1, 0, 0), DateTime(2020, 1, 1, 1, 0)]
        result2 = retime(int_ta2, new_ts2; downsample=:mean)
        @test eltype(values(result2)) == Float64
    end
end
