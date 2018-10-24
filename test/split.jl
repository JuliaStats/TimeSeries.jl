using Dates
using Test

using MarketData

using TimeSeries


@testset "split" begin


@testset "find methods" begin
    @testset "find returns correct row numbers array" begin
        @test timestamp(cl[findall(cl .> op)])[1] == Date(2000, 1, 3)
        @test length(findall(cl .> op))           == 244
    end

    @testset "findwhen returns correct Dates array" begin
       @test findwhen(cl .> op)[2]      == Date(2000, 1, 5)
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
        @test timestamp(when(cl, day, 4))[1]              == Date(2000,1,4)
        @test timestamp(when(cl, dayname, "Friday"))[1]   == Date(2000,1,7)
        @test timestamp(when(cl, week, 5))[1]             == Date(2000,1,31)
        @test timestamp(when(cl, month, 5))[1]            == Date(2000,5,1)
        @test timestamp(when(cl, monthname, "June"))[1]   == Date(2000,6,1)
        @test timestamp(when(cl, year, 2001))[1]          == Date(2001,1,2)
        @test timestamp(when(cl, dayofweek, 1))[1]        == Date(2000,1,3)
        # all the days in the nth week of each month
        @test timestamp(when(cl, dayofweekofmonth, 5))[1] == Date(2000,1,31)
        @test timestamp(when(cl, dayofyear, 365))[1]      == Date(2001,12,31)
        @test timestamp(when(cl, quarterofyear, 4))[1]    == Date(2000,10,2)
        @test timestamp(when(cl, dayofquarter, 1))[1]     == Date(2001,10,1)
    end
end


@testset "head, tail, first and last methods" begin
    @testset "head, tail, first and last methods work with default n value on single column TimeArray" begin
        @test length(head(cl,6))  == 6
        @test timestamp(head(cl)) == [Date(2000,1,3), Date(2000,1,4), Date(2000,1,5),
                                      Date(2000,1,6), Date(2000,1,7), Date(2000,1,10)]
        @test values(head(cl))    == [111.94, 102.5, 104.0, 95.0, 99.5, 97.75]

        @test length(tail(cl,6))  == 6
        @test timestamp(tail(cl)) == [Date(2001,12,21), Date(2001,12,24), Date(2001,12,26),
                                      Date(2001,12,27), Date(2001,12,28), Date(2001,12,31)]
        @test values(tail(cl))    == [21.0, 21.36, 21.49, 22.07, 22.43, 21.9]

        @test length(first(cl))       == 1
        @test timestamp(first(cl))[1] == Date(2000,1,3)
        @test values(first(cl))[1]    == 111.94
        @test meta(first(cl))         == "AAPL"

        @test length(last(cl))       == 1
        @test timestamp(last(cl))[1] == Date(2001,12,31)
        @test values(last(cl))[1]    == 21.9
        @test meta(last(cl))         == "AAPL"
    end

    @testset "head, tail, first and last methods work with default n value on multi column TimeArray" begin
        @test length(head(ohlc))         == 6
        @test values(head(ohlc, 1))      == [104.88 112.5 101.69 111.94]

        @test length(tail(ohlc))         == 6
        @test values(tail(ohlc, 1))      == [22.51 22.66 21.83 21.9]

        @test length(first(ohlc))       == 1
        @test timestamp(first(ohlc))[1] == Date(2000,1,3)
        @test values(first(ohlc))       == [104.88 112.5 101.69 111.94]
        @test meta(first(ohlc))         == "AAPL"

        @test length(last(ohlc))       == 1
        @test timestamp(last(ohlc))[1] == Date(2001,12,31)
        @test values(last(ohlc))       == [22.51 22.66 21.83 21.9]
        @test meta(last(ohlc))         == "AAPL"
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
