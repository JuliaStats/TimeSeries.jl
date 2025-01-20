using Dates
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
            @test Tables.rowaccess(typeof(cl))
            @test Tables.columnaccess(cl)
            @test Tables.columnaccess(typeof(cl))

            sch = Tables.schema(cl)
            @test sch.names == (:timestamp, :Close)
            @test sch.types == (Date, Float64)
        end

        @testset "multiple column" begin
            @test Tables.istable(ohlc)
            @test Tables.istable(typeof(ohlc))
            @test Tables.rowaccess(ohlc)
            @test Tables.rowaccess(typeof(ohlc))
            @test Tables.columnaccess(ohlc)
            @test Tables.columnaccess(typeof(ohlc))

            sch = Tables.schema(ohlc)
            @test sch.names == (:timestamp, :Open, :High, :Low, :Close)
            @test sch.types == (Date, Float64, Float64, Float64, Float64)
        end
    end

    @testset "iterator" begin
        @testset "single column" begin
            @test Tables.columnnames(cl) == [:timestamp; colnames(cl)]
            @test Tables.getcolumn(cl, 1) == timestamp(cl)
            @test Tables.getcolumn(cl, :timestamp) == timestamp(cl)
            @test Tables.getcolumn(cl, 2) == values(cl)
            @test Tables.getcolumn(cl, :Close) == values(cl)

            # column iterator
            iters = [Tables.columns(cl)]
            if VERSION ≥ v"1.1"
                push!(iters, eachcol(cl))
            end
            for i in iters
                @test size(i) == (length(cl), 2)
                @test length(i) == 2  # timestamp and the close columns
                @test i[100, 1] == timestamp(cl)[100]
                @test i[100, 2] == values(cl)[100]
                @test i[end] == values(cl)
                @test i[end, 1] == timestamp(cl)[end]
                @test i[end, 2] == values(cl)[end]
                @test timestamp(i) == timestamp(cl)
                @test colnames(i) == colnames(cl)
                @test i.Close == values(cl)
                @test Tables.getcolumn(i, 1) == timestamp(cl)
                @test Tables.getcolumn(i, :timestamp) == timestamp(cl)
                @test Tables.getcolumn(i, 2) == values(cl)
                @test Tables.getcolumn(i, :Close) == values(cl)

                @test propertynames(i) == (:timestamp, :Close)
            end

            # row iterator
            iters = [Tables.rows(cl)]
            if VERSION ≥ v"1.1"
                push!(iters, eachrow(cl))
            end
            for iter in iters
                for r in iter
                    @test r.timestamp == timestamp(cl)[1]
                    @test r.Close == values(cl)[1]
                    break
                end
            end
        end

        @testset "multi column" begin
            @test Tables.columnnames(ohlc) == [:timestamp; colnames(ohlc)]
            @test Tables.getcolumn(ohlc, 1) == timestamp(ohlc)
            @test Tables.getcolumn(ohlc, :timestamp) == timestamp(ohlc)
            @test Tables.getcolumn(ohlc, 3) == values(ohlc[:High])
            @test Tables.getcolumn(ohlc, :High) == values(ohlc[:High])

            # column iterator
            iters = [Tables.columns(ohlc)]
            if VERSION ≥ v"1.1"
                push!(iters, eachcol(ohlc))
            end
            for i in iters
                @test size(i) == (length(ohlc), 5)
                @test length(i) == 5
                @test i[100, 1] == timestamp(ohlc)[100]
                @test i[100, 3] == values(ohlc)[100, 2]
                @test i[end] == values(ohlc[:Close])
                @test i[end, 1] == timestamp(ohlc)[end]
                @test i[end, 3] == values(ohlc)[end, 2]
                @test timestamp(i) == timestamp(ohlc)
                @test colnames(i) == colnames(ohlc)
                @test i.Open == values(ohlc.Open)
                @test Tables.getcolumn(i, 1) == timestamp(ohlc)
                @test Tables.getcolumn(i, :timestamp) == timestamp(ohlc)
                @test Tables.getcolumn(i, 3) == values(ohlc[:High])
                @test Tables.getcolumn(i, :High) == values(ohlc[:High])

                @test propertynames(i) == (:timestamp, :Open, :High, :Low, :Close)
            end

            # row iterator
            iters = [Tables.rows(ohlc)]
            if VERSION ≥ v"1.1"
                push!(iters, eachrow(ohlc))
            end
            for iter in iters
                for r in iter
                    @test r.timestamp == timestamp(ohlc)[1]
                    @test r.Open == values(ohlc)[1, 1]
                    @test r.High == values(ohlc)[1, 2]
                    @test r.Low == values(ohlc)[1, 3]
                    @test r.Close == values(ohlc)[1, 4]
                    break
                end
            end
        end
    end  # @testset "iterator"

    @testset "DataFrames.jl" begin
        @testset "single column" begin
            df = DataFrame(cl)
            @test propertynames(df) == [:timestamp; colnames(cl)]
            @test df.timestamp == timestamp(cl)
            @test df.Close == values(cl.Close)
        end

        @testset "multi column" begin
            df = DataFrame(ohlc)
            @test propertynames(df) == [:timestamp; colnames(ohlc)]
            @test df.timestamp == timestamp(ohlc)
            @test df.Open == values(ohlc.Open)
            @test df.High == values(ohlc.High)
            @test df.Low == values(ohlc.Low)
            @test df.Close == values(ohlc.Close)
        end

        @testset "column name collision" begin
            ta = TimeArray(ohlc; colnames=[:Open, :High, :timestamp, :Close])
            df = DataFrame(ta)
            @test propertynames(df) == [:timestamp, :Open, :High, :timestamp_1, :Close]
            @test df.timestamp == timestamp(ta)
            @test df.Open == values(ta.Open)
            @test df.High == values(ta.High)
            @test df.timestamp_1 == values(ta.timestamp)
            @test df.Close == values(ta.Close)

            # no side effect on column renaming
            @test colnames(ta) == [:Open, :High, :timestamp, :Close]
        end

        @testset "DataFrame to TimeArray" begin
            ts = Date(2018, 1, 1):Day(1):Date(2018, 1, 3)
            df = DataFrame(; A=[1.0, 2, 3], B=[4, 5, 6], C=[7, 8, 9], ts=ts)
            for unchecked in (true, false)
                ta = TimeArray(df; timestamp=:ts, unchecked=unchecked)

                @test timestamp(ta) == ts
                @test colnames(ta) == [:A, :B, :C]
                @test meta(ta) ≡ df
                @test values(ta.A) == [1.0, 2, 3]
                @test values(ta.B) == [4, 5.0, 6]
                @test values(ta.C) == [7, 8, 9.0]
            end
        end
    end  # @testset "DataFrames.jl"

    @testset "CSV.jl" begin
        @testset "single column" begin
            ta = TimeArray(cl[1:5]; values=[1.1, 2.2, 3.3, 4.4, 5.5])
            io = IOBuffer()
            CSV.write(io, ta)
            @test String(take!(io)) ==
                "timestamp,Close\n" *
                  "2000-01-03,1.1\n" *
                  "2000-01-04,2.2\n" *
                  "2000-01-05,3.3\n" *
                  "2000-01-06,4.4\n" *
                  "2000-01-07,5.5\n"
        end

        @testset "multi column" begin
            ta = TimeArray(ohlc[1:5]; values=reshape(1.05:0.1:2.95, 5, :))
            io = IOBuffer()
            CSV.write(io, ta)
            @test String(take!(io)) ==
                "timestamp,Open,High,Low,Close\n" *
                  "2000-01-03,1.05,1.55,2.05,2.55\n" *
                  "2000-01-04,1.15,1.65,2.15,2.65\n" *
                  "2000-01-05,1.25,1.75,2.25,2.75\n" *
                  "2000-01-06,1.35,1.85,2.35,2.85\n" *
                  "2000-01-07,1.45,1.95,2.45,2.95\n"
        end

        @testset "read csv into TimeArray, single column" begin
            file =
                "timestamp,Close\n" *
                "2000-01-03,111.94\n" *
                "2000-01-04,102.5\n" *
                "2000-01-05,104\n" *
                "2000-01-06,95\n" *
                "2000-01-07,99.5\n"
            io = IOBuffer(file)
            csv = CSV.File(io)
            ta = TimeArray(csv; timestamp=:timestamp)
            ans = cl[1:5]
            @test timestamp(ta) == timestamp(ans)
            @test values(ta.Close) == values(ans.Close)
            @test meta(ta) ≡ csv
        end

        @testset "read csv into TimeArray, multi column" begin
            file =
                "timestamp,Open,High,Low,Close\n" *
                "2000-01-03,104.88,112.5,101.69,111.94\n" *
                "2000-01-04,108.25,110.62,101.19,102.5\n" *
                "2000-01-05,103.75,110.56,103,104\n" *
                "2000-01-06,106.12,107,95,95\n" *
                "2000-01-07,96.5,101,95.5,99.5\n"
            io = IOBuffer(file)
            csv = CSV.File(io)
            ta = TimeArray(csv; timestamp=:timestamp)
            ans = ohlc[1:5]
            @test timestamp(ta) == Date(2000, 1, 3):Day(1):Date(2000, 1, 7)
            @test values(ta.Open) == values(ans.Open)
            @test values(ta.High) == values(ans.High)
            @test values(ta.Low) == values(ans.Low)
            @test values(ta.Close) == values(ans.Close)
            @test meta(ta) ≡ csv
        end

        @testset "issue #442" begin
            file =
                "date,high,low,open,close,volume\n" *
                "1438992000,50.0,0.00262,50.0,0.00312499,1205.80332085\n" *
                "1439078400,0.0041,0.0024,0.00299999,0.00258069,898.12343401\n" *
                "1439164800,0.0029022,0.0022,0.00264996,0.00264498,718.36526568\n" *
                "1439251200,0.0044,0.002414,0.00264959,0.00395009,3007.27411094\n"
            io = IOBuffer(file)
            csv = CSV.File(io)
            ta = TimeArray(csv; timestamp=:date, timeparser=Date ∘ unix2datetime)
            @test timestamp(ta) == Date(2015, 8, 8):Day(1):Date(2015, 8, 11)
            @test colnames(ta) == [:high, :low, :open, :close, :volume]
        end
    end  # @testset "CSV.jl"
end  # @testset "Tables.jl integration
