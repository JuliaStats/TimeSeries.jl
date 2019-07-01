using Test

using TimeSeries
using MarketData
using DataFrames
using Tables
using CSV


@testset "Tables.jl integration" begin


@testset "interface" begin

    @testset "single column" begin
        @test Tables.istable(cl)
        @test Tables.istable(typeof(cl))
        @test Tables.rowaccess(cl)
        @test Tables.columnaccess(cl)

        sch = Tables.schema(cl)
        @test sch.names == (:timestamp, :Close)
        @test sch.types == (Date, Float64)
    end

    @testset "multiple column" begin
        @test Tables.istable(ohlc)
        @test Tables.istable(typeof(ohlc))
        @test Tables.rowaccess(ohlc)
        @test Tables.columnaccess(ohlc)

        sch = Tables.schema(ohlc)
        @test sch.names == (:timestamp, :Open, :High, :Low, :Close)
        @test sch.types == (Date, Float64, Float64, Float64, Float64)
    end
end


@testset "iterator" begin
    @testset "single column" begin
        # column iterator
        i = Tables.columns(cl)
        @test size(i)      == (length(cl), 2)
        @test length(i)    == 2  # timestamp and the close columns
        @test i[100, 1]    == timestamp(cl)[100]
        @test i[100, 2]    == values(cl)[100]
        @test i[end]       == values(cl)
        @test i[end, 1]    == timestamp(cl)[end]
        @test i[end, 2]    == values(cl)[end]
        @test timestamp(i) == timestamp(cl)
        @test colnames(i)  == colnames(cl)
        @test i.Close      == values(cl)

        @test propertynames(i) == (:timestamp, :Close)

        # row iterator
        i = Tables.rows(cl)
        for r ∈ i
            @test r.timestamp == timestamp(cl)[1]
            @test r.Close     == values(cl)[1]
            break
        end
    end

    @testset "multi column" begin
        # column iterator
        i = Tables.columns(ohlc)
        @test size(i)      == (length(ohlc), 5)
        @test length(i)    == 5
        @test i[100, 1]    == timestamp(ohlc)[100]
        @test i[100, 3]    == values(ohlc)[100, 2]
        @test i[end]       == values(ohlc[:Close])
        @test i[end, 1]    == timestamp(ohlc)[end]
        @test i[end, 3]    == values(ohlc)[end, 2]
        @test timestamp(i) == timestamp(ohlc)
        @test colnames(i)  == colnames(ohlc)
        @test i.Open       == values(ohlc.Open)

        @test propertynames(i) == (:timestamp, :Open, :High, :Low, :Close)

        # row iterator
        i = Tables.rows(ohlc)
        for r ∈ i
            @test r.timestamp == timestamp(ohlc)[1]
            @test r.Open      == values(ohlc)[1, 1]
            @test r.High      == values(ohlc)[1, 2]
            @test r.Low       == values(ohlc)[1, 3]
            @test r.Close     == values(ohlc)[1, 4]
            break
        end
    end
end  # @testset "iterator"


@testset "DataFrames.jl" begin
    @testset "single column" begin
        df = DataFrame(cl)
        @test names(df)    == [:timestamp; colnames(cl)]
        @test df.timestamp == timestamp(cl)
        @test df.Close     == values(cl.Close)
    end

    @testset "multi column" begin
        df = DataFrame(ohlc)
        @test names(df)    == [:timestamp; colnames(ohlc)]
        @test df.timestamp == timestamp(ohlc)
        @test df.Open      == values(ohlc.Open)
        @test df.High      == values(ohlc.High)
        @test df.Low       == values(ohlc.Low)
        @test df.Close     == values(ohlc.Close)
    end

    @testset "column name collision" begin
        ta = TimeArray(ohlc, colnames = [:Open, :High, :timestamp, :Close])
        df = DataFrame(ta)
        @test names(df)      == [:timestamp, :Open, :High, :timestamp_1, :Close]
        @test df.timestamp   == timestamp(ta)
        @test df.Open        == values(ta.Open)
        @test df.High        == values(ta.High)
        @test df.timestamp_1 == values(ta.timestamp)
        @test df.Close       == values(ta.Close)
    end

    @testset "DataFrame to TimeArray" begin
        ts = Date(2018, 1, 1):Day(1):Date(2018, 1, 3)
        df = DataFrame(A  = [1., 2, 3],
                       B  = [4, 5, 6],
                       C  = [7, 8, 9],
                       ts = ts)
        ta = TimeArray(df; timestamp = :ts)

        @test timestamp(ta) == ts
        @test colnames(ta)  == [:A, :B, :C]
        @test meta(ta)       ≡ df
        @test values(ta.A)  == [1., 2, 3]
        @test values(ta.B)  == [4, 5., 6]
        @test values(ta.C)  == [7, 8, 9.]
    end
end  # @testset "DataFrames.jl"


@testset "CSV.jl" begin
    @testset "single column" begin
        ta = TimeArray(cl[1:5], values = [1.1, 2.2, 3.3, 4.4, 5.5])
        io = IOBuffer()
        CSV.write(io, ta)
        @test String(take!(io)) == "timestamp,Close\n" *
                                   "2000-01-03,1.1\n" *
                                   "2000-01-04,2.2\n" *
                                   "2000-01-05,3.3\n" *
                                   "2000-01-06,4.4\n" *
                                   "2000-01-07,5.5\n"
    end

    @testset "multi column" begin
        ta = TimeArray(ohlc[1:5], values = reshape(1.05:.1:2.95, 5, :))
        io = IOBuffer()
        CSV.write(io, ta)
        @test String(take!(io)) == "timestamp,Open,High,Low,Close\n" *
                                   "2000-01-03,1.05,1.55,2.05,2.55\n" *
                                   "2000-01-04,1.15,1.65,2.15,2.65\n" *
                                   "2000-01-05,1.25,1.75,2.25,2.75\n" *
                                   "2000-01-06,1.35,1.85,2.35,2.85\n" *
                                   "2000-01-07,1.45,1.95,2.45,2.95\n"
    end

    @testset "read csv into TimeArray, single column" begin
        file = "timestamp,Close\n" *
               "2000-01-03,111.94\n" *
               "2000-01-04,102.5\n" *
               "2000-01-05,104\n" *
               "2000-01-06,95\n" *
               "2000-01-07,99.5\n"
        io = IOBuffer(file)
        csv = @static if VERSION ≥ v"1.0.0"
            CSV.File(io)
        else
            CSV.File(io, allowmissing = :none)
        end
        ta = TimeArray(csv, timestamp = :timestamp)
        ans = cl[1:5]
        @test timestamp(ta)   == timestamp(ans)
        @test values(ta.Close) == values(ans.Close)
        @test meta(ta)        ≡ csv
    end

    @testset "read csv into TimeArray, multi column" begin
        file = "timestamp,Open,High,Low,Close\n" *
               "2000-01-03,104.88,112.5,101.69,111.94\n" *
               "2000-01-04,108.25,110.62,101.19,102.5\n" *
               "2000-01-05,103.75,110.56,103,104\n" *
               "2000-01-06,106.12,107,95,95\n" *
               "2000-01-07,96.5,101,95.5,99.5\n"
        io = IOBuffer(file)
        csv = @static if VERSION ≥ v"1.0.0"
            CSV.File(io)
        else
            CSV.File(io, allowmissing = :none)
        end
        ta = TimeArray(csv, timestamp = :timestamp)
        ans = ohlc[1:5]
        @test timestamp(ta)    == Date(2000, 1, 3):Day(1):Date(2000, 1, 7)
        @test values(ta.Open)  == values(ans.Open)
        @test values(ta.High)  == values(ans.High)
        @test values(ta.Low)   == values(ans.Low)
        @test values(ta.Close) == values(ans.Close)
        @test meta(ta)         ≡ csv
    end
end  # @testset "CSV.jl"


end  # @testset "Tables.jl integration
