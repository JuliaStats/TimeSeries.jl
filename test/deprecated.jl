using Base.Dates
using Base.Test

using MarketData
using TimeSeries


# TODO: leverage `@test_warn` once drop 0.5 supporting
@testset "deprecated" begin


@testset "deprecated bydate methods correctly subset" begin
    @test by(mdata, 1, period=dayofweek).meta == "Apple"

    @test by(cl,4, period=day).timestamp[1]              == Date(2000,1,4)
    @test by(cl, "Friday", period=dayname).timestamp[1]  == Date(2000,1,7)
    @test by(cl,5, period=week).timestamp[1]             == Date(2000,1,31)
    @test by(cl,5, period=month).timestamp[1]            == Date(2000,5,1)
    @test by(cl, "June", period=monthname).timestamp[1]  == Date(2000,6,1)
    @test by(cl,2001, period=year).timestamp[1]          == Date(2001,1,2)
    @test by(cl,1, period=dayofweek).timestamp[1]        == Date(2000,1,3)
    # all the days in the nth week of each month
    @test by(cl,5, period=dayofweekofmonth).timestamp[1] == Date(2000,1,31)
    @test by(cl,365, period=dayofyear).timestamp[1]      == Date(2001,12,31)
    @test by(cl,4, period=quarterofyear).timestamp[1]    == Date(2000,10,2)
    @test by(cl,1, period=dayofquarter).timestamp[1]     == Date(2001,10,1)
end


@testset "deprecated to / from methods select correctly" begin
    @test to(cl, 2000, 01, 01).values    == to(cl, Date(2000, 01, 01)).values
    @test to(cl, 2001, 01, 01).values    == to(cl, Date(2001, 01, 01)).values
    @test to(cl, 2002, 01, 01).values    == to(cl, Date(2002, 01, 01)).values
    @test from(cl, 2000, 01, 01).values  == from(cl, Date(2000, 01, 01)).values
    @test from(cl, 2001, 01, 01).values  == from(cl, Date(2001, 01, 01)).values
    @test from(cl, 2002, 01, 01).values  == from(cl, Date(2002, 01, 01)).values
end


@testset "deprecated percentchange methods compute correct values" begin
    @test percentchange(op, method="simple").values == percentchange(op, :simple).values
    @test percentchange(op, method="log").values    == percentchange(op, :log).values
end


@testset "deprecated findall returns correct indices" begin
    @test findall(cl .> op) == find(cl .> op)
end


@testset "deprecated collapse squishes correctly" begin
    @test collapse(cl, last).values[1]                  == 99.50
    @test collapse(cl, last).timestamp[1]               == Date(2000,1,7)
    @test collapse(cl, last, period=month).values[1]    == 103.75
    @test collapse(cl, last, period=month).timestamp[1] == Date(2000,1,31)
end


@testset "non-dot operation between TimeArray values and Int/Float and viceversa" begin
    @test isapprox((cl - 100).values[1], 11.94, atol=0.1)
    @test isapprox((cl + 100).values[1], 211.94, atol=0.1)
    @test isapprox((cl * 100).values[1], 11194, atol=0.1)
    @test isapprox((cl / 100).values[1], 1.1194, atol=0.001)
    @test (cl % 2).values[1] == cl.values[1] % 2
    # not supported by Base - reserved for square matrix multiplication
    @test_throws MethodError (cl ^ 2).values[1]
    @test isapprox((100 - cl).values[1], -11.94, atol=0.1)
    @test isapprox((100 + cl).values[1], 211.94, atol=0.1)
    @test isapprox((100 * cl).values[1], 11194, atol=0.1)
    # not supported by Base - confusion with matrix inverse
    @test_throws MethodError (100 / cl).values
    # not supported by Base
    @test_throws MethodError (2 ^ cl).values
    @test (2 % cl).values[1]       == 2 % cl.values[1]
    @test (ohlc - 100).values[1,:] == ohlc.values[1,:] - 100
    @test (ohlc + 100).values[1,:] == ohlc.values[1,:] + 100
    @test (ohlc * 100).values[1,:] == ohlc.values[1,:] * 100
    @test (ohlc / 100).values[1,:] == ohlc.values[1,:] / 100
    # not supported by Base - reserved for square matrix multiplication
    @test_throws MethodError (ohlc ^ 2).values[1,:]
    @test (ohlc % 2).values[1,:]   == ohlc.values[1,:] % 2
    @test (100 - ohlc).values[1,:] == 100 - ohlc.values[1,:]
    @test (100 + ohlc).values[1,:] == 100 + ohlc.values[1,:]
    @test (100 * ohlc).values[1,:] == 100 * ohlc.values[1,:]
    # not supported by Base - confusion with matrix inverse
    @test_throws MethodError (100 / ohlc).values[1,:]
    # not supported by Base
    @test_throws MethodError (2 ^ ohlc).values[1,:]
    @test (2 % ohlc).values[1,:] == 2 % ohlc.values[1,:]
end


end  # @testset "deprecated"
