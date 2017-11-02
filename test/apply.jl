using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "apply" begin


@testset "time series methods" begin
    @testset "lag takes previous day and timestamps it to next day" begin
        @test isapprox(lag(cl).values[1]   , 111.94, atol=.01)
        @test lag(cl).timestamp[1] == Date(2000,1,4)
    end

    @testset "lag accepts other offset values" begin
        @test lag(cl, 9).timestamp[1] == Date(2000,1,14)
    end

    @testset "lag operates on 2d arrays" begin
        @test lag(ohlc, 9).timestamp[1] == Date(2000,1,14)
    end

    @testset "lag returns 1d from 1d time arrays" begin
        @test ndims(lag(cl).values) == 1
    end

    @testset "lag returns 2d from 2d time arrays" begin
        @test ndims(lag(ohlc).values) == 2
    end

    @testset "lead takes next day and timestamps it to current day" begin
        @test isapprox(lead(cl).values[1]   , 102.5, atol=.1)
        @test lead(cl).timestamp[1] == Date(2000,1,3)
    end

    @testset "lead accepts other offset values" begin
        @test lead(cl, 9).values[1]    == 100.44
        @test lead(cl, 9).timestamp[1] == Date(2000,1,3)
    end

    @testset "lead operates on 2d arrays" begin
        @test lead(ohlc, 9).timestamp[1] == Date(2000,1,3)
    end

    @testset "lead returns 1d from 1d time arrays" begin
        @test ndims(lead(cl).values) == 1
    end

    @testset "lead returns 2d from 2d time arrays" begin
        @test ndims(lead(ohlc).values) == 2
    end

    @testset "diff calculates 1st-order differences" begin
        @test diff(op).timestamp                              == diff(op, padding=false).timestamp
        @test diff(op).values                                 == diff(op, padding=false).values
        @test diff(op, padding=false).values[1]               == op[2].values[1] .- op[1].values[1]
        @test isequal(diff(op, padding=true).values[1], NaN)  == true
        @test diff(op, padding=true).values[2]                == diff(op).values[1]
        @test diff(op, padding=true).values[2]                == op[2].values[1] .- op[1].values[1]
    end

    @testset "simple return value" begin
        @test percentchange(cl, :simple).values == percentchange(cl).values
        @test percentchange(cl).values          == percentchange(cl, padding=false).values
        @test isapprox(percentchange(cl).values[1]                   , (102.5-111.94)/111.94, atol=.01)
        @test isapprox(percentchange(ohlc).values[1, :]              , (ohlc.values[2,:] - ohlc.values[1,:]) ./ ohlc.values[1,:])
        @test isnan.(percentchange(cl, padding=true).values[1])
        @test isapprox(percentchange(cl, padding=true).values[2]     , (102.5-111.94)/111.94, atol=.01)
        @test isapprox(percentchange(ohlc, padding=true).values[2, :], (ohlc.values[2,:] - ohlc.values[1,:]) ./ ohlc.values[1,:])
    end

    @testset "log return value" begin
        @test percentchange(cl, :log).values == percentchange(cl, :log, padding=false).values
        @test isapprox(percentchange(cl, :log).values[1]                   , log(102.5) - log(111.94), atol=.01)
        @test isapprox(percentchange(ohlc, :log).values[1, :]              , log.(ohlc.values[2,:]) .- log.(ohlc.values[1,:]), atol=.01)
        @test isnan.(percentchange(cl, :log, padding=true).values[1])
        @test isapprox(percentchange(cl, :log, padding=true).values[2]     , log(102.5) - log(111.94))
        @test isapprox(percentchange(ohlc, :log, padding=true).values[2, :], log.(ohlc.values[2,:]) .- log.(ohlc.values[1,:]))
    end

    @testset "moving supplies correct window length" begin
        @test moving(mean, cl, 10).values                                == moving(mean, cl, 10, padding=false).values
        @test moving(mean, cl, 10).timestamp[1]                          == Date(2000,1,14)
        @test isapprox(moving(mean, cl, 10).values[1], mean(cl.values[1:10]))
        @test moving(mean, cl, 10, padding=true).timestamp[1]            == Date(2000,1, 3)
        @test moving(mean, cl, 10, padding=true).timestamp[10]           == Date(2000,1,14)
        @test isequal(moving(mean, cl, 10, padding=true).values[1], NaN) == true
        @test moving(mean, cl, 10, padding=true).values[10]              == moving(mean, cl, 10).values[1]
        @test moving(mean, ohlc, 10).values                              == moving(mean, ohlc, 10, padding=false).values
        @test isapprox(moving(mean, ohlc, 10).values[1, :]', mean(ohlc.values[1:10, :], 1))
        @test isequal(moving(mean, ohlc, 10, padding=true).values[1, :], [NaN, NaN, NaN, NaN]) == true
        @test moving(mean, ohlc, 10, padding=true).values[10, :]         == moving(mean, ohlc, 10).values[1, :]

        @testset "moving with do syntax" begin
            moving(cl, 10) do x
                @test isa(x, Array{Float64, 1})
                x[1]
            end

            moving(ohlc, 10) do x
                @test isa(x, Array{Float64, 1})
                x[1]
            end
        end
    end

    @testset "upto method accumulates" begin
        @test isapprox(upto(sum, cl).values[10]       , sum(cl.values[1:10]))
        @test isapprox(upto(mean, cl).values[10]      , mean(cl.values[1:10]))
        @test upto(sum, cl).timestamp[10] == Date(2000,1,14)
        # transpose the upto value output from column to row vector but values are identical
        @test isapprox(upto(sum, ohlc).values[10, :]' , sum(ohlc.values[1:10, :], 1))
        @test isapprox(upto(mean, ohlc).values[10, :]', mean(ohlc.values[1:10, :], 1))
    end
end


@testset "basecall works with Base methods" begin
    @testset "cumsum works" begin
        @test basecall(cl, cumsum).values[2] == cl.values[1] + cl.values[2]
    end
end


@testset "adding/removing missing rows works" begin
    uohlc = uniformspace(ohlc[1:8])

    @testset "uniform spacing detection works" begin
        @test uniformspaced(datetime1)
        @test uniformspaced(uohlc)
        @test !uniformspaced(cl)
        @test !uniformspaced(ohlc)
    end

    @testset "forcing uniform spacing works" begin
        @test length(uohlc)                               == 10
        @test uohlc[5].values                             == ohlc[5].values
        @test isequal(uohlc[6].values, [NaN NaN NaN NaN]) == true
        @test isequal(uohlc[7].values, [NaN NaN NaN NaN]) == true
        @test uohlc[8].values                             == ohlc[6].values
    end

    @testset "dropnan works" begin
        nohlc = TimeArray(ohlc.timestamp, copy(ohlc.values), ohlc.colnames, ohlc.meta)
        nohlc.values[7:12, 2] = NaN

        @test dropnan(uohlc).timestamp       == dropnan(uohlc, :all).timestamp
        @test dropnan(uohlc).values          == dropnan(uohlc, :all).values

        @test dropnan(ohlc, :all).values     == ohlc.values
        @test dropnan(nohlc, :all).timestamp == ohlc.timestamp
        @test dropnan(uohlc, :all).timestamp == ohlc[1:8].timestamp
        @test dropnan(uohlc, :all).values    == ohlc[1:8].values

        @test dropnan(ohlc, :any).values     == ohlc.values
        @test dropnan(nohlc, :any).timestamp == ohlc.timestamp[[1:6;13:end]]
        @test dropnan(nohlc, :any).values    == ohlc.values[[1:6;13:end], :]
        @test dropnan(uohlc, :any).timestamp == ohlc[1:8].timestamp
        @test dropnan(uohlc, :any).values    == ohlc[1:8].values
    end
end


end  # @testset "apply"
