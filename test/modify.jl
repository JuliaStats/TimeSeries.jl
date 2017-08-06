using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "modify" begin


@testset "update method works" begin
    new_cls  = update(cl, today(), 111.11)
    new_clv  = update(cl, today(), [111.11])
    new_ohlc = update(ohlc, today(), [111.11 222.22 333.33 444.44])
    empty1   = TimeArray(Vector{Date}(), Array{Int}(0,1))
    empty2   = TimeArray(Vector{Date}(), Array{Int}(0,2))

    @testset "empty time arrays can be constructed" begin
        @test length(empty1) == 0
        @test length(empty2) == 0
    end

    @testset "update an empty time array fails" begin
        @test_throws ArgumentError update(empty1, Date(2000,1,1), 10)
        @test_throws ArgumentError update(empty2, Date(2000,1,1), [10 11])
        # @test length(update1)      == 1
        # @test length(update2)      == 1
        # @test update1.timestamp[1] == Date(2000,1,1)
        # @test update2.timestamp[1] == Date(2000,1,1)
        # @test update1.values       == [12]
        # @test update2.values       == [10 11]
        # @test update1.colnames     == ["foo"]
        # @test update2.colnames     == ["foo", "bar"]
        # @test update1.meta         == "bar"
        # @test update2.meta         == "baz"
    end

    @testset "update a single column time array with single value vector" begin
        @test last(new_clv.values) == 111.11
        @test_throws DimensionMismatch update(cl, today(), [111.11, 222.22])
    end

    @testset "update a multi column time array" begin
        # @test last(new_ohlc).values == [111.11 222.22 333.33 444.44]
        @test tail(new_ohlc).values == [111.11 222.22 333.33 444.44]
        @test_throws MethodError update(ohlc, today(), [111.11, 222.22, 333.33])
    end

    @testset "cannot update more than one observation at a time" begin
        @test_throws(
            MethodError,
            update(cl, [Date(2002,1,1), Date(2002,1,2)], [111.11, 222,22]))
    end

    @testset "cannot update oldest observations" begin
        @test_throws ArgumentError update(cl, Date(1999,1,1), [111.11])
        @test_throws ArgumentError update(cl, Date(1999,1,1), 111.11)
    end

    @testset "cannot update in-between observations" begin
        @test_throws ArgumentError update(cl, Date(2000,1,8), [111.11])
        @test_throws ArgumentError update(cl, Date(2000,1,8), 111.11)
    end
end


@testset "rename method works" begin
    re_ohlc = rename(ohlc, ["a","b","c","d"])
    re_cl   = rename(cl, ["vector"])
    re_cls  = rename(cl, "string")

    @testset "change colnames with multi-member vector" begin
        @test colnames(re_ohlc) == ["a","b","c","d"]
        @test_throws DimensionMismatch rename(ohlc, ["a"])
    end

    @testset "change colnames with single-member vector" begin
        @test colnames(re_cl) == ["vector"]
        @test_throws DimensionMismatch rename(cl, ["a", "b"])
    end

    @testset "change colnames with string" begin
        @test colnames(re_cls) == ["string"]
        @test_throws MethodError rename(cl, "string_a", "string_b")
    end
end


end  # @testset "modify"
