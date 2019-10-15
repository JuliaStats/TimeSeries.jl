using Test

using TimeSeries

@testset "plotrecipes" begin

@testset "the Candlestick constructor works" begin
    timearray = let 
        dates = dates = Date(2018, 1, 1):Day(1):Date(2018, 3, 31)
        TimeArray(dates, rand(length(dates)))
    end
    candlestick = TimeSeries.Candlestick(timearray)
    @test length(canclestick.time) == length(timearray)
end

end # @testset "plotrecipes