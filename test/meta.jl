using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "meta" begin


@testset "construction with and without meta field" begin
    nometa = TimeArray(cl.timestamp, cl.values, cl.colnames)

    @testset "default meta field to nothing" begin
        @test nometa.meta == nothing
    end

    @testset "allow objects in meta field" begin
        @test mdata.meta == "Apple"
    end
end


@testset "get index operations preserve meta" begin
    @testset "index by integer row" begin
        @test mdata[1].meta == "Apple"
    end

    @testset "index by integer range" begin
        @test mdata[1:2].meta == "Apple"
    end

    @testset "index by column name" begin
        @test mdata["Close"].meta == "Apple"
    end

    @testset "index by date range" begin
        @test mdata[[Date(2000,1,3), Date(2000,1,14)]].meta == "Apple"
    end
end


@testset "split operations preserve meta" begin
    @testset "when" begin
        @test when(mdata, dayofweek, 1).meta == "Apple"
    end

    @testset "from" begin
        @test from(mdata, Date(2000,1,1)).meta == "Apple"
    end

    @testset "to" begin
        @test to(mdata, Date(2000,1,1)).meta == "Apple"
    end
end


@testset "apply operations preserve meta" begin
    @testset "lag" begin
        @test lag(mdata).meta == "Apple"
    end

    @testset "lead" begin
        @test lead(mdata).meta == "Apple"
    end

    @testset "percentchange" begin
        @test percentchange(mdata).meta == "Apple"
    end

    @testset "moving" begin
        @test moving(mdata,mean,10).meta == "Apple"
    end

    @testset "upto" begin
        @test upto(sum, mdata).meta == "Apple"
    end
end


@testset "combine operations preserve meta" begin
    @testset "merge when both have identical meta" begin
        @test merge(cl, op).meta         == "AAPL"
        @test merge(cl, op, :left).meta  == "AAPL"
        @test merge(cl, op, :right).meta == "AAPL"
        @test merge(cl, op, :outer).meta == "AAPL"
    end

    @testset "merged meta field value concatenates when both objects' meta field values are strings" begin
        @test merge(mdata, cl).meta         == "Apple_AAPL"
        @test merge(mdata, cl, :left).meta  == "Apple_AAPL"
        @test merge(mdata, cl, :right).meta == "Apple_AAPL"
        @test merge(mdata, cl, :outer).meta == "Apple_AAPL"
    end

    @testset "merge when supplied with meta" begin
        @test merge(mdata, mdata, meta=47).meta         == 47
        @test merge(mdata, mdata, :left, meta=47).meta  == 47
        @test merge(mdata, mdata, :right, meta=47).meta == 47
        @test merge(mdata, mdata, :outer, meta=47).meta == 47
        @test merge(mdata, cl, meta=47).meta            == 47
        @test merge(mdata, cl, :left, meta=47).meta     == 47
        @test merge(mdata, cl, :right, meta=47).meta    == 47
        @test merge(mdata, cl, :outer, meta=47).meta    == 47
    end

    @testset "merged meta field value for disparate types in meta field defaults to Void" begin
        @test merge(mdata, merge(cl, op, meta=47)).meta         == Void
        @test merge(mdata, merge(cl, op, meta=47), :left).meta  == Void
        @test merge(mdata, merge(cl, op, meta=47), :right).meta == Void
        @test merge(mdata, merge(cl, op, meta=47), :outer).meta == Void
    end

    @testset "collapse" begin
        @test collapse(mdata, week, first).meta == "Apple"
    end
end


@testset "basecall operations preserve meta" begin
    @testset "basecall" begin
        @test basecall(mdata, cumsum).meta == "Apple"
    end
end


@testset "mathematical and comparison operations preserve meta" begin
    @testset ".+" begin
        @test (mdata .+ mdata).meta == "Apple"
        @test (mdata .+ cl).meta == Void
    end

    @testset ".<" begin
        @test (mdata .< mdata).meta == "Apple"
        @test (mdata .< cl).meta == Void
    end
end


@testset "readwrite accepts meta argument" begin
    @testset "Apple is present" begin
        @test mdata.meta == "Apple"
    end
end


end  # @testset "meta"
