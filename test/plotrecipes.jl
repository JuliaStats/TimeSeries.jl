using Test

using MarketData
using TimeSeries


@testset "plotrecipes" begin


@testset "the Candlestick constructor works" begin
    candlestick = TimeSeries.Candlestick(ohlcv)
    @test length(candlestick.time) == length(ohlcv)

    candlestick = TimeSeries.Candlestick(ohlc)
    @test length(candlestick.time) == length(ohlc)

    @test_throws ArgumentError TimeSeries.Candlestick(cl)
    @test_throws ArgumentError TimeSeries.Candlestick(op)
end


end # @testset "plotrecipes
