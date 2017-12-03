using Base.Test

using MarketData

using TimeSeries


@testset "basemisc" begin


@testset "cumulative functions" begin
    let ta = cumsum(cl)
        @test ta.values == cumsum(cl.values)
        @test ta.meta == cl.meta
    end

    let ta = cumsum(ohlc)
        @test ta.values == cumsum(ohlc.values)
        @test ta.meta == ohlc.meta
    end

    let ta = cumsum(cl, 2)
        @test ta.values == cumsum(cl.values, 2)
        @test ta.meta == cl.meta
    end

    let ta = cumsum(ohlc, 2)
        @test ta.values == cumsum(ohlc.values, 2)
        @test ta.meta == ohlc.meta
    end

    @test_throws DimensionMismatch cumsum(cl, 3)
    @test_throws DimensionMismatch cumsum(ohlc, 3)

    let ta = cumprod(cl[1:5])
        @test ta.values == cumprod(cl[1:5].values)
        @test ta.meta == cl[1:5].meta
    end

    let ta = cumprod(ohlc[1:5])
        @test ta.values == cumprod(ohlc[1:5].values)
        @test ta.meta == ohlc[1:5].meta
    end

    let ta = cumprod(cl[1:5], 2)
        @test ta.values == cumprod(cl[1:5].values, 2)
        @test ta.meta == cl[1:5].meta
    end

    let ta = cumprod(ohlc[1:5], 2)
        @test ta.values == cumprod(ohlc[1:5].values, 2)
        @test ta.meta == ohlc[1:5].meta
    end

    @test_throws DimensionMismatch cumprod(cl, 3)
    @test_throws DimensionMismatch cumprod(ohlc, 3)
end

@testset "reduction functions" begin
    for (fname, f) ∈ ([(:sum, sum), (:mean, mean)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test ta.meta == src.meta
                    @test length(ta) == 1
                    @test ta.values == f(src.values, 1)
                end

                let ta = f(src, 2)
                    @test ta.meta == src.meta
                    @test length(ta) == length(src.timestamp)
                    @test ta.values == f(src.values, 2)
                    @test ta.colnames == [string(fname)]
                end

                @test_throws DimensionMismatch f(src, 3)
            end  # @testset
        end
    end  # for func

    for (fname, f) ∈ ([(:std, std), (:var, var)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test ta.meta == src.meta
                    @test length(ta) == 1
                    @test ta.values == f(src.values, 1)
                end

                let ta = f(src, 2, corrected=false)
                    @test ta.meta == src.meta
                    @test length(ta) == length(src.timestamp)
                    @test ta.values == f(src.values, 2, corrected=false)
                    @test ta.colnames == [string(fname)]
                end

                @test_throws DimensionMismatch f(src, 3)
            end  # @testset
        end
    end  # for func
end


end  # @testset "basemisc"
