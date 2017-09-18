using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "combine" begin


@testset "collapse operations" begin
    @testset "collapse squishes correctly" begin
        @test collapse(cl, week, first).values[2]    == 97.75
        @test collapse(cl, week, first).timestamp[2] == Date(2000,1,10)

        @test collapse(cl, week, first, last).values[2]    == 100.44
        @test collapse(cl, week, first, last).timestamp[2] == Date(2000,1,10)

        @test collapse(cl, month, first).values[2]    == 100.25
        @test collapse(cl, month, first).timestamp[2] == Date(2000,2,1)

        @test collapse(ohlc, week, first).values[2, :] == [102.0, 102.25, 94.75, 97.75]
        @test collapse(ohlc, week, first).timestamp[2] == Date(2000,1,10)

        @test collapse(ohlc, week, first, last).values[2, :] == [100.0, 102.25, 99.38, 100.44]
        @test collapse(ohlc, week, first, last).timestamp[2] == Date(2000,1,10)

        @test collapse(ohlc, month, first).values[2, :] == [104.0, 105.0, 100.0, 100.25]
        @test collapse(ohlc, month, first).timestamp[2] == Date(2000,2,1)
    end
end


@testset "merge works correctly" begin
    cl1  = cl[1:3]
    op1  = cl[2:4]
    aapl = tail(AAPL)
    ba   = tail(BA)

    @testset "takes colnames kwarg correctly" begin
        @test merge(cl, ohlc["High", "Low"], colnames=["a","b","c"]).colnames == ["a", "b", "c"]
        @test merge(cl, op, colnames=["a","b"]).colnames                      == ["a", "b"]
        @test_throws ErrorException merge(cl, op, colnames=["a"])
        @test_throws ErrorException merge(cl, op, colnames=["a","b","c"])

        @test merge(cl, ohlc["High", "Low"], :inner, colnames=["a","b","c"]).colnames == ["a", "b", "c"]
        @test merge(cl, op, :inner, colnames=["a","b"]).colnames == ["a", "b"]
        @test_throws ErrorException merge(cl, op, :inner, colnames=["a"])
        @test_throws ErrorException merge(cl, op, :inner, colnames=["a","b","c"])

        @test merge(cl, ohlc["High", "Low"], :left, colnames=["a","b","c"]).colnames == ["a", "b", "c"]
        @test merge(cl, op, :left, colnames=["a","b"]).colnames          == ["a", "b"]
        @test_throws ErrorException merge(cl, op, :left, colnames=["a"])
        @test_throws ErrorException merge(cl, op, :left, colnames=["a","b","c"])

        @test merge(cl, ohlc["High", "Low"], :right, colnames=["a","b","c"]).colnames == ["a", "b", "c"]
        @test merge(cl, op, :right, colnames=["a","b"]).colnames == ["a", "b"]
        @test_throws ErrorException merge(cl, op, :right, colnames=["a"])
        @test_throws ErrorException merge(cl, op, :right, colnames=["a","b","c"])

        @test merge(cl, ohlc["High", "Low"], :outer, colnames=["a","b","c"]).colnames == ["a", "b", "c"]
        @test merge(cl, op, :outer, colnames=["a","b"]).colnames == ["a", "b"]
        @test_throws ErrorException merge(cl, op, :outer, colnames=["a"])
        @test_throws ErrorException merge(cl, op, :outer, colnames=["a","b","c"])
    end

    @testset "returns correct alignment with Dates and values" begin
        @test merge(cl,op).values == merge(cl,op, :inner).values
        @test merge(cl,op).values[2,1] == cl.values[2,1]
        @test merge(cl,op).values[2,2] == op.values[2,1]
    end

    @testset "aligns with disparate sized objects" begin
        @test merge(cl, op[2:5]).values[1,1]  == cl.values[2,1]
        @test merge(cl, op[2:5]).values[1,2]  == op.values[2,1]
        @test merge(cl, op[2:5]).timestamp[1] == Date(2000,1,4)
        @test length(merge(cl, op[2:5]))      == 4

        @test length(merge(cl1, op1, :inner))     == 2
        @test merge(cl1, op1, :inner).values[2,1] == cl1.values[3,1]
        @test merge(cl1, op1, :inner).values[2,2] == op1.values[2,1]

        @test length(merge(cl1, op1, :left))     == 3
        @test merge(cl1, op1, :left).values[2,1] == cl1.values[2,1]
        @test merge(cl1, op1, :left).values[2,2] == op1.values[1,1]
        @test isnan(merge(cl1,op1, :left).values[1,2])

        @test length(merge(cl1, op1, :right))     == 3
        @test merge(cl1, op1, :right).values[2,1] == cl1.values[3,1]
        @test merge(cl1, op1, :right).values[2,2] == op1.values[2,1]
        @test isnan(merge(cl1, op1, :right).values[3,1])

        @test length(merge(cl1, op1, :outer))     == 4
        @test merge(cl1, op1, :outer).values[2,1] == cl1.values[2,1]
        @test merge(cl1, op1, :outer).values[2,2] == op1.values[1,1]
        @test isnan(merge(cl1, op1, :outer).values[1,2])
        @test isnan(merge(cl1, op1, :outer).values[4,1])
    end

    @testset "column names match the correct values" begin
        @test merge(cl, op[2:5]).colnames         == ["Close", "Open"]
        @test merge(op[2:5], cl).colnames         == ["Open", "Close"]

        @test merge(cl, op[2:5], :inner).colnames == ["Close", "Open"]
        @test merge(op[2:5], cl, :inner).colnames == ["Open", "Close"]

        @test merge(cl, op[2:5], :left).colnames  == ["Close", "Open"]
        @test merge(op[2:5], cl, :left).colnames  == ["Open", "Close"]

        @test merge(cl, op[2:5], :right).colnames == ["Close", "Open"]
        @test merge(op[2:5], cl, :right).colnames == ["Open", "Close"]

        @test merge(cl, op[2:5], :outer).colnames == ["Close", "Open"]
        @test merge(op[2:5], cl, :outer).colnames == ["Open", "Close"]
    end

    @testset "unknown method" begin
        @test_throws ArgumentError merge(cl, op, :unknown)
    end
end


@testset "vcat works correctly" begin
    @testset "concatenates time series correctly in 1D" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 12, 01)], [17], ["Number"])
        c = vcat(a, b)

        @test length(c)  == (length(a) + length(b))
        @test c.colnames == a.colnames
        @test c.colnames == b.colnames
        @test c.values   == [15, 16, 17]
    end

    @testset "concatenates time series correctly in 2D" begin
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], ["Number 1", "Number 2"])
        b = TimeArray([Date(2015, 12, 01)], [18 18], ["Number 1", "Number 2"])
        c = vcat(a, b)

        @test length(c)  == length(a) + length(b)
        @test c.colnames == a.colnames
        @test c.colnames == b.colnames
        @test c.values   == [[15 16]; [17 18]; [19 20]; [18 18]]
    end

    @testset "rejects when column names do not match" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 12, 01)], [17], ["Data does not match number"])

        @test_throws ArgumentError vcat(a, b)
    end

    @testset "rejects when metas do not match" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"], :FirstMeta)
        b = TimeArray([Date(2015, 12, 01)], [17], ["Number"], :SecondMeta)

        @test_throws ArgumentError vcat(a, b)
    end

    @testset "rejects when dates overlap" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 11, 01)], [17], ["Number"])

        @test_throws ArgumentError vcat(a, b)
    end

    @testset "still works when dates are mixed" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 17], ["Number"])
        b = TimeArray([Date(2015, 11, 01)], [16], ["Number"])
        c = vcat(a, b)

        @test length(c)  == length(a) + length(b)
        @test c.colnames == a.colnames
        @test c.colnames == b.colnames
        @test c.values   == [15, 16, 17]
        @test issorted(c.timestamp)
    end
end


@testset "map works correctly" begin
    @testset "works on both time stamps and 1D values" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"], :Something)
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), values - 1), a)

        @test length(b)                  == length(a)
        @test b.colnames                 == a.colnames
        @test Dates.year(b.timestamp[1]) == Dates.year(a.timestamp[1]) + 1
        @test b.values[1]                == a.values[1] - 1
        @test b.meta                     == a.meta
    end

    @testset "works on both time stamps and 2D values" begin
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], ["Number 1", "Number 2"])
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), [values[1] + 2, values[2] - 1]), a)

        @test length(b)                  == length(a)
        @test b.colnames                 == a.colnames
        @test Dates.year(b.timestamp[1]) == Dates.year(a.timestamp[1]) + 1
        @test b.values[1, 1]             == a.values[1, 1] + 2
        @test b.values[1, 2]             == a.values[1, 2] - 1
    end

    @testset "works with order of elements that varies after modifications" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 16], ["Number"])
        b = map((timestamp, values) -> (timestamp + Dates.Year((timestamp >= Date(2015, 11, 01)) ? -1 : 1), values), a)

        @test length(b) == length(a)
        @test issorted(b.timestamp)
    end
end


end  # @testset "combine"
