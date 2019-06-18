using Dates
using Statistics
using Test

using MarketData

using TimeSeries


@testset "meta" begin


@testset "construction with and without meta field" begin
    nometa = TimeArray(timestamp(cl), values(cl), colnames(cl))

    @testset "default meta field to nothing" begin
        @test meta(nometa) == nothing
    end

    @testset "allow objects in meta field" begin
        @test meta(mdata) == "Apple"
    end
end


@testset "get index operations preserve meta" begin
    @testset "index by integer row" begin
        @test meta(mdata[1]) == "Apple"
    end

    @testset "index by integer range" begin
        @test meta(mdata[1:2]) == "Apple"
    end

    @testset "index by column name" begin
        @test meta(mdata[:Close]) == "Apple"
    end

    @testset "index by date range" begin
        @test meta(mdata[[Date(2000,1,3), Date(2000,1,14)]]) == "Apple"
    end
end


@testset "split operations preserve meta" begin
    @testset "when" begin
        @test meta(when(mdata, dayofweek, 1)) == "Apple"
    end

    @testset "from" begin
        @test meta(from(mdata, Date(2000,1,1))) == "Apple"
    end

    @testset "to" begin
        @test meta(to(mdata, Date(2000,1,1))) == "Apple"
    end
end


@testset "apply operations preserve meta" begin
    @testset "lag" begin
        @test meta(lag(mdata)) == "Apple"
    end

    @testset "lead" begin
        @test meta(lead(mdata)) == "Apple"
    end

    @testset "percentchange" begin
        @test meta(percentchange(mdata)) == "Apple"
    end

    @testset "moving" begin
        @test meta(moving(mean,mdata,10)) == "Apple"
    end

    @testset "upto" begin
        @test meta(upto(sum, mdata)) == "Apple"
    end
end


@testset "combine operations preserve meta" begin
    @testset "merge when both have identical meta" begin
        @test meta(merge(cl, op))                  == "AAPL"
        @test meta(merge(cl, op, method = :left))  == "AAPL"
        @test meta(merge(cl, op, method = :right)) == "AAPL"
        @test meta(merge(cl, op, method = :outer)) == "AAPL"
    end

    @testset "merged meta field value concatenates when both objects' meta field values are strings" begin
        @test meta(merge(mdata, cl))                  == "Apple_AAPL"
        @test meta(merge(mdata, cl, method = :left))  == "Apple_AAPL"
        @test meta(merge(mdata, cl, method = :right)) == "Apple_AAPL"
        @test meta(merge(mdata, cl, method = :outer)) == "Apple_AAPL"
    end

    @testset "merge when supplied with meta" begin
        @test meta(merge(mdata, mdata, meta=47))                  == 47
        @test meta(merge(mdata, mdata, method = :left, meta=47))  == 47
        @test meta(merge(mdata, mdata, method = :right, meta=47)) == 47
        @test meta(merge(mdata, mdata, method = :outer, meta=47)) == 47
        @test meta(merge(mdata, cl, meta=47))                     == 47
        @test meta(merge(mdata, cl, method = :left, meta=47))     == 47
        @test meta(merge(mdata, cl, method = :right, meta=47))    == 47
        @test meta(merge(mdata, cl, method = :outer, meta=47))    == 47
    end

    @testset "merged meta field value for disparate types in meta field defaults to Void" begin
        @test meta(merge(mdata, merge(cl, op, meta=47)))                  == nothing
        @test meta(merge(mdata, merge(cl, op, meta=47), method = :left))  == nothing
        @test meta(merge(mdata, merge(cl, op, meta=47), method = :right)) == nothing
        @test meta(merge(mdata, merge(cl, op, meta=47), method = :outer)) == nothing
    end

    @testset "collapse" begin
        @test meta(collapse(mdata, week, first)) == "Apple"
    end
end


@testset "basecall operations preserve meta" begin
    @testset "basecall" begin
        @test meta(basecall(mdata, cumsum)) == "Apple"
    end
end


@testset "mathematical and comparison operations preserve meta" begin
    @testset ".+" begin
        @test meta(mdata .+ mdata) == "Apple"
        @test meta(mdata .+ cl)    == nothing
    end

    @testset ".<" begin
        @test meta(mdata .< mdata) == "Apple"
        @test meta(mdata .< cl)    == nothing
    end
end


@testset "readwrite accepts meta argument" begin
    @testset "Apple is present" begin
        @test meta(mdata) == "Apple"
    end
end


end  # @testset "meta"
