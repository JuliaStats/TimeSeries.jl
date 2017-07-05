using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "readwrite" begin


@testset "readwrite parses IO correctly" begin
    io  = """DateTime,Open
             2010/1/4|9:01:00,7300
             2010/1/4|9:02:00,7316
             2010/1/4|9:03:00,7316
             2010/1/4|9:04:00,7316
             2010/1/4|9:05:00,7316"""
    tm0 = readtimearray(IOBuffer(io), format="yyyy/mm/dd|HH:MM:SS")

    @testset "Input as IOBuffer and specifying DateTime string format for reading" begin
        @test length(tm0)      == 5
        @test size(tm0.values) == (5,1)
        @test tm0.timestamp[4] == DateTime(2010,1,4,9,4)
    end
end


@testset "readwrite parses csv correctly" begin
    tm1 = readtimearray(
        joinpath(dirname(@__FILE__), "data/datetime3.csv"),
        format="yyyy/mm/dd|HH:MM:SS")
    tm2 = readtimearray(
        joinpath(dirname(@__FILE__), "data/datetime3.csv"),
        format="yyyy/mm/dd|HH:MM:SS", meta="foo")
    tm3 = readtimearray(
        joinpath(dirname(@__FILE__), "data/read_example_delim.csv"),
        format="dd/mm/yyyy HH:MM", delim=';')

    @testset "Specifying DateTime string format for reading" begin
        @test length(tm1)      == 5
        @test size(tm1.values) == (5,1)
        @test tm1.timestamp[4]  == DateTime(2010,1,4,9,4)
        @test_throws(
            ArgumentError,
            readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv")))
    end

    @testset "readtimearray accepts meta field" begin
        @test tm2.meta == "foo"
    end

    @testset "readtimearray works with arbitrary delimiters" begin
        @test length(tm3)      == 2
        @test size(tm3.values) == (2,2)
        @test tm3.timestamp[2] == DateTime(2015,1,1,1,0)
        @test tm3.values[1,1]  == 10.42
    end
end


@testset "readwrite parses MarketData objects correctly" begin
    @testset "1d values array works" begin
        @test typeof(cl.values) == Array{Float64,1}
    end

    @testset "2d values array works" begin
        @test typeof(ohlc.values) == Array{Float64,2}
    end

    @testset "timestamp parses to correct type" begin
        @test typeof(cl.timestamp)        == Vector{Date}
        @test typeof(datetime1.timestamp) == Vector{DateTime}
    end
end


@testset "writetimearray method works" begin
    filename = "$(randstring()).csv"
    uohlc    = uniformspace(ohlc)
    writetimearray(uohlc, filename)
    readback = readtimearray(filename)

    @testset "writetimearray output can be round-tripped" begin
        @test uohlc.colnames                         == readback.colnames
        @test uohlc.timestamp                        == readback.timestamp
        @test isequal(uohlc.values, readback.values) == true
        rm(filename)
    end
end


end  # @testset "readwrite"
