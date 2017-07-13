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
        @test isnan(percentchange(cl, padding=true).values[1])
        @test isapprox(percentchange(cl, padding=true).values[2]     , (102.5-111.94)/111.94, atol=.01)
        @test isapprox(percentchange(ohlc, padding=true).values[2, :], (ohlc.values[2,:] - ohlc.values[1,:]) ./ ohlc.values[1,:])
    end

    @testset "log return value" begin
        @test percentchange(cl, :log).values == percentchange(cl, :log, padding=false).values
        @test isapprox(percentchange(cl, :log).values[1]                   , log(102.5) - log(111.94), atol=.01)
        @test isapprox(percentchange(ohlc, :log).values[1, :]              , log(ohlc.values[2,:]) - log(ohlc.values[1,:]), atol=.01)
        @test isnan(percentchange(cl, :log, padding=true).values[1])
        @test isapprox(percentchange(cl, :log, padding=true).values[2]     , log(102.5) - log(111.94))
        @test isapprox(percentchange(ohlc, :log, padding=true).values[2, :], log(ohlc.values[2,:]) - log(ohlc.values[1,:]))
    end

    @testset "moving supplies correct window length" begin
        @test moving(cl, mean, 10).values                                == moving(cl, mean, 10, padding=false).values
        @test moving(cl, mean, 10).timestamp[1]                          == Date(2000,1,14)
        @test isapprox(moving(cl, mean, 10).values[1], mean(cl.values[1:10]))
        @test moving(cl, mean, 10, padding=true).timestamp[1]            == Date(2000,1, 3)
        @test moving(cl, mean, 10, padding=true).timestamp[10]           == Date(2000,1,14)
        @test isequal(moving(cl, mean, 10, padding=true).values[1], NaN) == true
        @test moving(cl, mean, 10, padding=true).values[10]              == moving(cl, mean, 10).values[1]
        @test moving(ohlc, mean, 10).values                              == moving(ohlc, mean, 10, padding=false).values
        @test isapprox(moving(ohlc, mean, 10).values[1, :]', mean(ohlc.values[1:10, :], 1))
        @test isequal(moving(ohlc, mean, 10, padding=true).values[1, :], [NaN, NaN, NaN, NaN]) == true
        @test moving(ohlc, mean, 10, padding=true).values[10, :]         == moving(ohlc, mean, 10).values[1, :]
    end

    @testset "upto method accumulates" begin
        @test isapprox(upto(cl, sum).values[10]       , sum(cl.values[1:10]))
        @test isapprox(upto(cl, mean).values[10]      , mean(cl.values[1:10]))
        @test upto(cl, sum).timestamp[10] == Date(2000,1,14)
        # transpose the upto value output from column to row vector but values are identical
        @test isapprox(upto(ohlc, sum).values[10, :]' , sum(ohlc.values[1:10, :], 1))
        @test isapprox(upto(ohlc, mean).values[10, :]', mean(ohlc.values[1:10, :], 1))
    end
end


@testset "base element-wise operators on TimeArray values" begin
    @testset "only values on intersecting Dates computed" begin
        @test isapprox((cl[1:2] ./ op[2:3]).values[1], 0.94688222)
        @test isapprox((cl[1:4] .+ op[4:7]).values[1], 201.12, atol=.01)
        @test length(cl[1:2] ./ op[2:3]) == 1
        @test length(cl[1:4] .+ op[4:7]) == 1
    end

    @testset "unary operation on TimeArray values" begin
        @test (+cl).values[1]                == cl.values[1]
        @test (-cl).values[1]                == -cl.values[1]
        @test (!(cl .== op)).values[1]       == true
        @test log(cl).values[1]              == log(cl.values[1])
        @test sqrt(cl).values[1]             == sqrt(cl.values[1])
        @test (+ohlc).values[1,:]            == ohlc.values[1,:]
        @test (-ohlc).values[1,:]            == -(ohlc.values[1,:])
        @test (!(ohlc .== ohlc)).values[1,1] == false
        @test log(ohlc).values[1, :]         == log(ohlc.values[1, :])
        @test sqrt(ohlc).values[1, :]        == sqrt(ohlc.values[1, :])
        @test_throws DomainError sqrt(-ohlc)
    end

    @testset "dot operation between TimeArray values and Int/Float and viceversa" begin
        @test isapprox((cl .- 100).values[1]    , 11.94, atol=.01)
        @test isapprox((cl .+ 100).values[1]    , 211.94, atol=.01)
        @test isapprox((cl .* 100).values[1]    , 11194, atol=1)
        @test isapprox((cl ./ 100).values[1]    , 1.1194, atol=.0001)
        @test isapprox((cl .^ 2).values[1]      , 12530.5636, atol=.0001)
        @test (cl .% 2).values[1] == cl.values[1] % 2
        @test isapprox((100 .- cl).values[1]    , -11.94, atol=.01)
        @test isapprox((100 .+ cl).values[1]    , 211.94, atol=.01)
        @test isapprox((100 .* cl).values[1]    , 11194, atol=.01)
        @test isapprox((100 ./ cl).values[1]    , 0.8933357155619082)
        @test (2 .^ cl).values[1]       == 4980784073277740581384811358191616
        @test (2 .% cl).values[1]       == 2
        @test (ohlc .- 100).values[1,:] == ohlc.values[1,:] .- 100
        @test (ohlc .+ 100).values[1,:] == ohlc.values[1,:] .+ 100
        @test (ohlc .* 100).values[1,:] == ohlc.values[1,:] .* 100
        @test (ohlc ./ 100).values[1,:] == ohlc.values[1,:] ./ 100
        @test (ohlc .^ 2).values[1,:]   == ohlc.values[1,:] .^ 2
        @test (ohlc .% 2).values[1,:]   == ohlc.values[1,:] .% 2
        @test (100 .- ohlc).values[1,:] == 100 .- ohlc.values[1,:]
        @test (100 .+ ohlc).values[1,:] == 100 .+ ohlc.values[1,:]
        @test (100 .* ohlc).values[1,:] == 100 .* ohlc.values[1,:]
        @test (100 ./ ohlc).values[1,:] == 100 ./ ohlc.values[1,:]
        @test (2 .^ ohlc).values[1,:]   == 2 .^ ohlc.values[1,:]
        @test (2 .% ohlc).values[1,:]   == 2 .% ohlc.values[1,:]
    end

    @testset "mathematical operations between two same-column-count TimeArrays" begin
        @test isapprox((cl .+ op).values[1], 216.82, atol=.01)
        @test isapprox((cl .- op).values[1], 7.06, atol=.01)
        @test isapprox((cl .* op).values[1], 11740.2672, atol=0.0001)
        @test isapprox((cl ./ op).values[1], 1.067315, atol=0.001)
        @test (cl .% op).values                                 == cl.values .% op.values
        @test (cl .^ op).values                                 == cl.values .^ op.values
        @test (cl .* (cl.> 200)).values                         == cl.values .* (cl.values .> 200)
        @test (basecall(cl, x->round(Int, x)) .* cl).values     == round(Int, cl.values) .* cl.values
        @test (ohlc .+ ohlc).values                             == ohlc.values .+ ohlc.values
        @test (ohlc .- ohlc).values                             == ohlc.values .- ohlc.values
        @test (ohlc .* ohlc).values                             == ohlc.values .* ohlc.values
        @test (ohlc ./ ohlc).values                             == ohlc.values ./ ohlc.values
        @test (ohlc .% ohlc).values                             == ohlc.values .% ohlc.values
        @test (ohlc .^ ohlc).values                             == ohlc.values .^ ohlc.values
        @test (ohlc .* (ohlc .> 200)).values                    == ohlc.values .* (ohlc.values .> 200)
        @test (basecall(ohlc, x->round(Int, x)) .* ohlc).values == round(Int, ohlc.values) .* ohlc.values
    end

    @testset "broadcasted mathematical operations between different-column-count TimeArrays" begin
        @test (ohlc .+ cl).values                             == ohlc.values .+ cl.values
        @test (ohlc .- cl).values                             == ohlc.values .- cl.values
        @test (ohlc .* cl).values                             == ohlc.values .* cl.values
        @test (ohlc ./ cl).values                             == ohlc.values ./ cl.values
        @test (ohlc .% cl).values                             == ohlc.values .% cl.values
        @test (ohlc .^ cl).values                             == ohlc.values .^ cl.values
        @test (ohlc .* (cl.> 200)).values                     == ohlc.values .* (cl.values .> 200)
        @test (basecall(ohlc, x->round(Int, x)) .* cl).values == round(Int, ohlc.values) .* cl.values
        @test (cl .+ ohlc).values                             == cl.values .+ ohlc.values
        @test (cl .- ohlc).values                             == cl.values .- ohlc.values
        @test (cl .* ohlc).values                             == cl.values .* ohlc.values
        @test (cl ./ ohlc).values                             == cl.values ./ ohlc.values
        @test (cl .% ohlc).values                             == cl.values .% ohlc.values
        @test (cl .^ ohlc).values                             == cl.values .^ ohlc.values
        @test (cl .* (ohlc .> 200)).values                    == cl.values .* (ohlc.values .> 200)
        @test (basecall(cl, x->round(Int, x)) .* ohlc).values == round(Int, cl.values) .* ohlc.values
        # One array must have a single column
        @test_throws ErrorException (ohlc["Open", "Close"] .+ ohlc)
    end

    @testset "comparison operations between TimeArray values and Int/Float (and viceversa)" begin
        @test (cl .> 111.94).values[1]      == false
        @test (cl .< 111.94).values[1]      == false
        @test (cl .>= 111.94).values[1]     == true
        @test (cl .<= 111.94).values[1]     == true
        @test (cl .== 111.94).values[1]     == true
        @test (cl .!= 111.94).values[1]     == false
        @test (111.94 .> cl).values[1]      == false
        @test (111.94 .< cl).values[1]      == false
        @test (111.94 .>= cl).values[1]     == true
        @test (111.94 .<= cl).values[1]     == true
        @test (111.94 .== cl).values[1]     == true
        @test (111.94 .!= cl).values[1]     == false
        @test (ohlc .> 111.94).values[1,:]  == [false, true, false, false]
        @test (ohlc .< 111.94).values[1,:]  == [true, false, true, false]
        @test (ohlc .>= 111.94).values[1,:] == [false, true, false, true]
        @test (ohlc .<= 111.94).values[1,:] == [true, false, true, true]
        @test (ohlc .== 111.94).values[1,:] == [false, false, false, true]
        @test (ohlc .!= 111.94).values[1,:] == [true, true, true, false]
        @test (111.94 .> ohlc).values[1,:]  == [true, false, true, false]
        @test (111.94 .< ohlc).values[1,:]  == [false, true, false, false]
        @test (111.94 .>= ohlc).values[1,:] == [true, false, true, true]
        @test (111.94 .<= ohlc).values[1,:] == [false, true, false, true]
        @test (111.94 .== ohlc).values[1,:] == [false, false, false, true]
        @test (111.94 .!= ohlc).values[1,:] == [true, true, true, false]
    end

    @testset "comparison operations between TimeArray values and Bool (and viceversa)" begin
        @test ((cl .> 111.94) .== true).values[1]     == false
        @test ((cl .> 111.94) .!= true).values[1]     == true
        @test (true .== (cl .> 111.94)).values[1]     == false
        @test (true .!= (cl .> 111.94)).values[1]     == true
        @test ((ohlc .> 111.94).== true).values[1,:]  == [false, true, false, false]
        @test ((ohlc .> 111.94).!= true).values[1,:]  == [true, false, true, true]
        @test (true .== (ohlc .> 111.94)).values[1,:] == [false, true, false, false]
        @test (true .!= (ohlc .> 111.94)).values[1,:] == [true, false, true, true]
    end

    @testset "comparison operations between same-column-count TimeArrays" begin
        @test (cl .> op).values[1]        == true
        @test (cl .< op).values[1]        == false
        @test (cl .<= op).values[1]       == false
        @test (cl .>= op).values[1]       == true
        @test (cl .== op).values[1]       == false
        @test (cl .!= op).values[1]       == true
        @test (ohlc .> ohlc).values[1,:]  == [false, false, false, false]
        @test (ohlc .< ohlc).values[1,:]  == [false, false, false, false]
        @test (ohlc .<= ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .>= ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .== ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .!= ohlc).values[1,:] == [false, false, false, false]
    end

    @testset "comparison operations between different-column-count TimeArrays" begin
        @test (ohlc .> cl).values  == (ohlc.values .> cl.values)
        @test (ohlc .< cl).values  == (ohlc.values .< cl.values)
        @test (ohlc .>= cl).values == (ohlc.values .>= cl.values)
        @test (ohlc .<= cl).values == (ohlc.values .<= cl.values)
        @test (ohlc .== cl).values == (ohlc.values .== cl.values)
        @test (ohlc .!= cl).values == (ohlc.values .!= cl.values)
        @test (cl .> ohlc).values  == (cl.values .> ohlc.values)
        @test (cl .< ohlc).values  == (cl.values .< ohlc.values)
        @test (cl .>= ohlc).values == (cl.values .>= ohlc.values)
        @test (cl .<= ohlc).values == (cl.values .<= ohlc.values)
        @test (cl .== ohlc).values == (cl.values .== ohlc.values)
        @test (cl .!= ohlc).values == (cl.values .!= ohlc.values)
        # One array must have a single column
        @test_throws ErrorException (ohlc["Open", "Close"] .== ohlc)
    end

    @testset "bitwise elementwise operations between bool and TimeArrays' values" begin
        @test ((cl .> 100) & true).values[1]      == true
        @test ((cl .> 100) | true).values[1]      == true
        @test ((cl .> 100) $ true).values[1]      == false
        @test (false & (cl .> 100)).values[1]     == false
        @test (false | (cl .> 100)).values[1]     == true
        @test (false $ (cl .> 100)).values[1]     == true
        @test ((ohlc .> 100) & true).values[4,:]  == [true, true, false, false]
        @test ((ohlc .> 100) | true).values[4,:]  == [true, true, true, true]
        @test ((ohlc .> 100) $ true).values[4,:]  == [false, false, true, true]
        @test (false & (ohlc .> 100)).values[4,:] == [false, false, false, false]
        @test (false | (ohlc .> 100)).values[4,:] == [true, true, false, false]
        @test (false $ (ohlc .> 100)).values[4,:] == [true, true, false, false]
      end

    @testset "bitwise elementwise operations between same-column-count TimeArrays' boolean values" begin
        @test ((cl .> 100) & (cl .< 120)).values[1]       == true
        @test ((cl .> 100) | (cl .< 120)).values[1]       == true
        @test ((cl .> 100) $ (cl .< 120)).values[1]       == false
        @test ((ohlc .> 100) & (ohlc .< 120)).values[4,:] == [true, true, false, false]
        @test ((ohlc .> 100) | (ohlc .< 120)).values[4,:] == [true, true, true, true]
        @test ((ohlc .> 100) $ (ohlc .< 120)).values[4,:] == [false, false, true, true]
        # Bitwise broadcasting not supported by Base
        @test_throws MethodError ((ohlc .> 100) $ (cl.< 120))
    end
end


@testset "basecall works with Base methods" begin
    @testset "cumsum works" begin
        @test basecall(cl, cumsum).values[2] == cl.values[1] + cl.values[2]
    end

    @testset "log works" begin
        @test basecall(cl, log).values[2] == log(cl.values[2])
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
