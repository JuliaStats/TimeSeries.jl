using Base.Test

using MarketData

using TimeSeries


@testset "basemisc" begin


@testset "cumsum" begin
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
end


end  # @testset "basemisc"
