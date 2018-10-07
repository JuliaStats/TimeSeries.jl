using Dates
using Test

using MarketData

using TimeSeries


@testset "split" begin


@testset "find methods" begin
    @testset "find returns correct row numbers array" begin
        @test cl[findall(cl .> op)].timestamp[1] == Date(2000,1,3)
        @test length(findall(cl .> op))          == 244
    end

    @testset "findwhen returns correct Dates array" begin
       @test findwhen(cl .> op)[2]      == Date(2000,1,5)
       @test length(findwhen(cl .> op)) == 244
    end
end


@testset "split date operations" begin
    @testset "from and to correctly subset non-zero and zero-length time arrays" begin
        @test length(from(cl, Date(2001,12,28))) == 2
        @test length(from(cl, Date(2002,1,1)))   == 0
        @test length(from(from(cl, Date(2002,1,1)), Date(2012,1,1))) == 0

        @test length(to(cl, Date(2000,1,4)))     == 2
        @test length(to(cl, Date(1999,1,4)))     == 0
        @test length(to(to(cl, Date(1999,1,4)), Date(1912,1,1))) == 0
    end

    @testset "when method correctly subset" begin
        @test when(cl, day, 4).timestamp[1]              == Date(2000,1,4)
        @test when(cl, dayname, "Friday").timestamp[1]   == Date(2000,1,7)
        @test when(cl, week, 5).timestamp[1]             == Date(2000,1,31)
        @test when(cl, month, 5).timestamp[1]            == Date(2000,5,1)
        @test when(cl, monthname, "June").timestamp[1]   == Date(2000,6,1)
        @test when(cl, year, 2001).timestamp[1]          == Date(2001,1,2)
        @test when(cl, dayofweek, 1).timestamp[1]        == Date(2000,1,3)
        # all the days in the nth week of each month
        @test when(cl, dayofweekofmonth, 5).timestamp[1] == Date(2000,1,31)
        @test when(cl, dayofyear, 365).timestamp[1]      == Date(2001,12,31)
        @test when(cl, quarterofyear, 4).timestamp[1]    == Date(2000,10,2)
        @test when(cl, dayofquarter, 1).timestamp[1]     == Date(2001,10,1)
    end
end


@testset "element wrappers" begin
    @testset "type element wrappers isolate elements" begin
        for ta ∈ [cl, ohlc]
            @test timestamp(ta) isa Vector{Date}
            @test values(ta)    isa Array{Float64}
            @test colnames(ta)  isa Vector{Symbol}
        end
    end
end


@testset "head, tail, first and last methods" begin
    @testset "head, tail, first and last methods work with default n value on single column TimeArray" begin
        @test length(head(cl,6)) == 6
        @test head(cl).timestamp == [Date(2000,1,3), Date(2000,1,4), Date(2000,1,5), Date(2000,1,6), Date(2000,1,7), Date(2000,1,10)]
        @test head(cl).values    == [111.94, 102.5, 104.0, 95.0, 99.5, 97.75]

        @test length(tail(cl,6)) == 6
        @test tail(cl).timestamp == [Date(2001,12,21), Date(2001,12,24), Date(2001,12,26), Date(2001,12,27), Date(2001,12,28), Date(2001,12,31)]
        @test tail(cl).values    ==  [21.0, 21.36, 21.49, 22.07, 22.43, 21.9]

        @test length(first(cl))      == 1
        @test first(cl).timestamp[1] == Date(2000,1,3)
        @test first(cl).values[1]    == 111.94
        @test first(cl).meta         == "AAPL"

        @test length(last(cl))      == 1
        @test last(cl).timestamp[1] == Date(2001,12,31)
        @test last(cl).values[1]    == 21.9
        @test last(cl).meta         == "AAPL"
    end

    @testset "head, tail, first and last methods work with default n value on multi column TimeArray" begin
        @test length(head(ohlc))       == 6
        @test head(ohlc,1).values      == [104.88 112.5 101.69 111.94]

        @test length(tail(ohlc))       == 6
        @test tail(ohlc,1).values      == [22.51 22.66 21.83 21.9]

        @test length(first(ohlc))      == 1
        @test first(ohlc).timestamp[1] == Date(2000,1,3)
        @test first(ohlc).values       == [104.88 112.5 101.69 111.94]
        @test first(ohlc).meta         == "AAPL"

        @test length(last(ohlc))      == 1
        @test last(ohlc).timestamp[1] == Date(2001,12,31)
        @test last(ohlc).values       == [22.51 22.66 21.83 21.9]
        @test last(ohlc).meta         == "AAPL"
    end

    @testset "head, tail, first and last methods work with custom periods on single column TimeArray" begin
        @test length(head(cl, 2))   == 2
        @test length(head(cl, 500)) == length(cl)
        @test length(tail(cl, 2))   == 2
        @test length(tail(cl, 500)) == length(cl)

        @test length(first(cl))     == 1
        @test length(last(cl))      == 1
    end

    @testset "head, tail, first and last methods work with custom periods on multi column TimeArray" begin
        @test length(head(ohlc, 2))   == 2
        @test length(head(ohlc, 500)) == length(ohlc)
        @test length(tail(ohlc, 2))   == 2
        @test length(tail(ohlc, 500)) == length(ohlc)

        @test length(first(ohlc))     == 1
        @test length(last(ohlc))      == 1
    end
end


end  # @testset "split"
