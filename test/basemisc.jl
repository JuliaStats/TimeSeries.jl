using Statistics
using Test

using MarketData

using TimeSeries


@testset "basemisc" begin


@testset "cumulative functions" begin
    let ta = cumsum(cl)
        @test values(ta) == cumsum(values(cl))
        @test meta(ta) == meta(cl)
    end

    let ta = cumsum(ohlc, dims = 1)
        @test values(ta) == cumsum(values(ohlc), dims = 1)
        @test meta(ta) == meta(ohlc)
    end

    let ta = cumsum(cl, dims = 2)
        @test values(ta) == cumsum(values(cl), dims = 2)
        @test meta(ta) == meta(cl)
    end

    let ta = cumsum(ohlc, dims = 2)
        @test values(ta) == cumsum(values(ohlc), dims = 2)
        @test meta(ta) == meta(ohlc)
    end

    @test_throws DimensionMismatch cumsum(cl, dims = 3)
    @test_throws DimensionMismatch cumsum(ohlc, dims = 3)

    let ta = cumprod(cl[1:5])
        @test values(ta) == cumprod(values(cl[1:5]))
        @test meta(ta) == meta(cl[1:5])
    end

    let ta = cumprod(ohlc[1:5], dims = 1)
        @test values(ta) == cumprod(values(ohlc[1:5]), dims = 1)
        @test meta(ta) == meta(ohlc[1:5])
    end

    let ta = cumprod(cl[1:5], dims = 2)
        @test values(ta) == cumprod(values(cl[1:5]), dims = 2)
        @test meta(ta) == meta(cl[1:5])
    end

    let ta = cumprod(ohlc[1:5], dims = 2)
        @test values(ta) == cumprod(values(ohlc[1:5]), dims = 2)
        @test meta(ta) == meta(ohlc[1:5])
    end

    @test_throws DimensionMismatch cumprod(cl, dims = 3)
    @test_throws DimensionMismatch cumprod(ohlc, dims = 3)
end

@testset "reduction functions" begin
    for (fname, f) ∈ ([(:sum, sum), (:mean, mean)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test meta(ta)   == meta(src)
                    @test length(ta) == 1
                    @test values(ta) == f(values(src), dims = 1)
                end

                let ta = f(src, dims = 2)
                    @test meta(ta)     == meta(src)
                    @test length(ta)   == length(timestamp(src))
                    @test values(ta)   == f(values(src), dims = 2)
                    @test colnames(ta) == [fname]
                end

                @test_throws DimensionMismatch f(src, dims = 3)
            end  # @testset
        end
    end  # for func

    for (fname, f) ∈ ([(:std, std), (:var, var)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test meta(ta)   == meta(src)
                    @test length(ta) == 1
                    @test values(ta) == f(values(src), dims = 1)
                end

                let ta = f(src, dims = 2, corrected = false)
                    @test meta(ta)     == meta(src)
                    @test length(ta)   == length(timestamp(src))
                    @test values(ta)   == f(values(src), dims = 2, corrected = false)
                    @test colnames(ta) == [fname]
                end

                @test_throws DimensionMismatch f(src, dims = 3)
            end  # @testset
        end
    end  # for func
end


@testset "Base.any function" begin
    let  # single column
        """
        julia> any(x .== lag(x))
        1x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-07 to 2000-01-07
        │            │ _     │
        ├────────────┼───────┤
        │ 2000-01-07 │ false │
        """
        let
            ts = timestamp(cl)[1:5]
            ta = TimeArray(ts, 1:5)
            xs = any(ta .== lag(ta))
            @test timestamp(xs)[1] == ts[end]
            @test values(xs)[1]    == false
        end

        """
        julia> any(x .== lag(x), 2)
        4x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-04 to 2000-01-07
        │            │ any   │
        ├────────────┼───────┤
        │ 2000-01-04 │ false │
        │ 2000-01-05 │ true  │
        │ 2000-01-06 │ false │
        │ 2000-01-07 │ false │
        """
        let
            ts = timestamp(cl)[1:5]
            ta = TimeArray(ts, [1, 2, 2, 3, 4])
            xs = any(ta .== lag(ta), dims = 2)

            @test timestamp(xs)   == ts[2:end]
            @test any(values(xs) .== [false, true, false, false])
            @test colnames(xs)    == [:any]
        end
    end  # single column

    let  # multi column
        """
        julia> x .> 3
        3x2 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
        │            │ A     │ B     │
        ├────────────┼───────┼───────┤
        │ 2000-01-03 │ false │ false │
        │ 2000-01-04 │ false │ true  │
        │ 2000-01-05 │ true  │ true  │

        julia> any(x .> 3, 2)
        3x1 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
        │            │ any   │
        ├────────────┼───────┤
        │ 2000-01-03 │ false │
        │ 2000-01-04 │ true  │
        │ 2000-01-05 │ true  │
        """
        ts = timestamp(cl)[1:3]
        ta = TimeArray(ts, [1 2; 3 4; 5 6])
        xs = any(ta .> 3, dims = 2)

        @test timestamp(xs) == ts
        @test any(values(xs) .== [false, true, true])
        @test colnames(xs) == [:any]
    end  # multi column
end  # @testset "Base.any" function


@testset "Base.all function" begin
    let  # single column
        """
        julia> all(x .== lag(x))
        1x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-07 to 2000-01-07
        │            │ A     │
        ├────────────┼───────┤
        │ 2000-01-07 │ false │
        """
        let
            ts = timestamp(cl)[1:5]
            ta = TimeArray(ts, 1:5)
            xs = all(ta .== lag(ta))
            @test timestamp(xs)[] == ts[end]
            @test values(xs)[]    == false
        end

        """
        julia> all(x .== lag(x), 2)
        4x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-04 to 2000-01-07
        │            │ any   │
        ├────────────┼───────┤
        │ 2000-01-04 │ false │
        │ 2000-01-05 │ true  │
        │ 2000-01-06 │ false │
        │ 2000-01-07 │ false │
        """
        let
            ts = timestamp(cl)[1:5]
            ta = TimeArray(ts, [1, 2, 2, 3, 4])
            xs = all(ta .== lag(ta), dims = 2)

            @test timestamp(xs) == ts[2:end]
            @test all(values(xs) .== [false, true, false, false])
            @test colnames(xs) == [:all]
        end
    end  # single column

    let  # multi column
        """
        julia> x .> 3
        3x2 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
        │            │ A     │ B     │
        ├────────────┼───────┼───────┤
        │ 2000-01-03 │ false │ false │
        │ 2000-01-04 │ false │ true  │
        │ 2000-01-05 │ true  │ true  │

        julia> all(x .> 3, 2)
        3x1 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
        │            │ all   │
        ├────────────┼───────┤
        │ 2000-01-03 │ false │
        │ 2000-01-04 │ false │
        │ 2000-01-05 │ true  │
        """
        ts = timestamp(cl)[1:3]
        ta = TimeArray(ts, [1 2; 3 4; 5 6])
        xs = all(ta .> 3, dims = 2)

        @test timestamp(xs) == ts
        @test all(values(xs) .== [false, false, true])
        @test colnames(xs) == [:all]
    end  # multi column
end  # @testset "Base.all" function


end  # @testset "basemisc"
