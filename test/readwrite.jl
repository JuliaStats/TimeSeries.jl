using Dates
using Random
using Test

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
        @test length(tm0)       == 5
        @test size(values(tm0)) == (5,1)
        @test timestamp(tm0)[4] == DateTime(2010,1,4,9,4)
    end
end


@testset "readwrite parses csv correctly" begin
    tm1 = readtimearray(
        joinpath(@__DIR__, "data/datetime3.csv"),
        format="yyyy/mm/dd|HH:MM:SS")
    tm2 = readtimearray(
        joinpath(@__DIR__, "data/datetime3.csv"),
        format="yyyy/mm/dd|HH:MM:SS", meta="foo")
    tm3 = readtimearray(
        joinpath(@__DIR__, "data/read_example_delim.csv"),
        format="dd/mm/yyyy HH:MM", delim=';')
    tm4 = readtimearray(
        joinpath(@__DIR__, "data/headless.csv"),
        format="yyyy-mm-dd HH:MM:SS", header=false)

    @testset "Specifying DateTime string format for reading" begin
        @test length(tm1)        == 5
        @test size(values(tm1))  == (5,1)
        @test timestamp(tm1)[4]  == DateTime(2010,1,4,9,4)
        @test_throws(
            ArgumentError,
            readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv")))
    end

    @testset "readtimearray accepts meta field" begin
        @test meta(tm2) == "foo"
    end

    @testset "readtimearray works with arbitrary delimiters" begin
        @test length(tm3)       == 2
        @test size(values(tm3)) == (2,2)
        @test timestamp(tm3)[2] == DateTime(2015,1,1,1,0)
        @test values(tm3)[1,1]  == 10.42
    end

    @testset "headless csv" begin
        @test length(tm4)       == 2
        @test size(values(tm4)) == (2, 4)
        @test values(tm4)       == [1 2 3 4; 5 6 7 8]
    end
end


@testset "readwrite parses MarketData objects correctly" begin
    @testset "1d values array works" begin
        @test typeof(values(cl)) == Array{Float64,1}
    end

    @testset "2d values array works" begin
        @test typeof(values(ohlc)) == Array{Float64,2}
    end

    @testset "timestamp parses to correct type" begin
        @test typeof(timestamp(cl))        == Vector{Date}
        @test typeof(timestamp(datetime1)) == Vector{DateTime}
    end
end


@testset "writetimearray method with default parameters works" begin
    mktemp() do filename, _io
        uohlc = uniformspace(ohlc)
        writetimearray(uohlc, filename)
        readback = readtimearray(filename)

        @test colnames(uohlc)  == colnames(readback)
        @test timestamp(uohlc) == timestamp(readback)
        @test isequal(values(uohlc), values(readback))
    end
end

@testset "writetimearray method with a delimiter works" begin
    mktemp() do filename, _io
        uohlc = uniformspace(ohlc)
        writetimearray(uohlc[1:5], filename, delim=';')
        readback = readtimearray(filename, delim=';')

        @test colnames(uohlc[1:5])  == colnames(readback)
        @test timestamp(uohlc[1:5]) == timestamp(readback)
        @test isequal(values(uohlc[1:5]), values(readback))
    end
end

@testset "writetimearray method with no header works" begin
    mktemp() do filename, _io
        uohlc = uniformspace(ohlc)
        writetimearray(uohlc[1:5], filename, header=false)
        readback = readtimearray(filename, header=false)

        @test timestamp(uohlc[1:5]) == timestamp(readback)
        @test isequal(values(uohlc[1:5]), values(readback))
    end
end

@testset "writetimearray method with a timestamp format works" begin
    mktemp() do filename, _io
        uohlc = uniformspace(ohlc)
        writetimearray(uohlc[1:5], filename, format="yyyy/mm/dd")
        readback = readtimearray(filename, format="yyyy/mm/dd")

        @test timestamp(uohlc[1:5]) == timestamp(readback)
    end
end

end  # @testset "readwrite"
