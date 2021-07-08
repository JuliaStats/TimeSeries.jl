using Dates
using Test

using MarketData

using TimeSeries


struct _TestType
end


@testset "combine" begin


@testset "collapse operations" begin
    @testset "collapse squishes correctly" begin
        @test values(collapse(cl, week, first))[2]    == 97.75
        @test timestamp(collapse(cl, week, first))[2] == Date(2000,1,10)

        @test values(collapse(cl, week, first, last))[2]    == 100.44
        @test timestamp(collapse(cl, week, first, last))[2] == Date(2000,1,10)

        @test values(collapse(cl, month, first))[2]    == 100.25
        @test timestamp(collapse(cl, month, first))[2] == Date(2000,2,1)

        @test values(collapse(ohlc, week, first))[2, :] == [102.0, 102.25, 94.75, 97.75]
        @test timestamp(collapse(ohlc, week, first))[2] == Date(2000,1,10)

        @test values(collapse(ohlc, week, first, last))[2, :] == [100.0, 102.25, 99.38, 100.44]
        @test timestamp(collapse(ohlc, week, first, last))[2] == Date(2000,1,10)

        @test values(collapse(ohlc, month, first))[2, :] == [104.0, 105.0, 100.0, 100.25]
        @test timestamp(collapse(ohlc, month, first))[2] == Date(2000,2,1)

        # https://github.com/JuliaStats/TimeSeries.jl/issues/498
        if VERSION ≥ v"1.6"
            let  # quarter
                ts = [
                    Date(2018, 1, 2),
                    Date(2018, 1, 3),
                    Date(2019, 1, 5),
                    Date(2019, 2, 6),
                ]
                ta = TimeArray(ts, 1:length(ts))
                ta′ = collapse(ta, Dates.quarter, last)
                @test values(ta′)    == [2, 4]
                @test timestamp(ta′) == ts[[2, 4]]
                @test ta′            == collapse(ta, Quarter(1), last)
            end
        end
        let  # week
            ts = [
                Date(2018, 1, 2),
                Date(2018, 1, 3),
                Date(2019, 1, 5),
                Date(2019, 2, 6),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, week, last)
            @test values(ta′)    == [2, 3, 4]
            @test timestamp(ta′) == ts[[2, 3, 4]]
            @test ta′            == collapse(ta, Week(1), last)
        end
        let  # month
            ts = [
                Date(2018, 1, 2),
                Date(2018, 1, 3),
                Date(2019, 1, 10),
                Date(2019, 2, 5),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, month, last)
            @test values(ta′)    == [2, 3, 4]
            @test timestamp(ta′) == ts[[2, 3, 4]]
            @test ta′            == collapse(ta, Month(1), last)
        end
        let  # day
            ts = [
                DateTime(2018, 1, 2, 10),
                DateTime(2018, 1, 2, 12),
                DateTime(2018, 2, 2, 12),
                DateTime(2018, 2, 2, 14),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, day, last)
            @test values(ta′)    == [2, 4]
            @test timestamp(ta′) == ts[[2, 4]]
            @test ta′            == collapse(ta, Day(1), last)
        end
        let  # hour
            ts = [
                DateTime(2018, 1, 2, 10, 0),
                DateTime(2018, 1, 2, 12, 0),
                DateTime(2018, 2, 2, 12, 0),
                DateTime(2018, 2, 2, 12, 30),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, hour, last)
            @test values(ta′)    == [1, 2, 4]
            @test timestamp(ta′) == ts[[1, 2, 4]]
            @test ta′            == collapse(ta, Hour(1), last)
        end
        let  # minute
            ts = [
                DateTime(2018, 1, 2, 12, 0),
                DateTime(2018, 1, 2, 12, 0, 30),
                DateTime(2018, 1, 2, 13, 0),
                DateTime(2018, 1, 2, 13, 0),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, minute, last)
            @test values(ta′)    == [2, 4]
            @test timestamp(ta′) == ts[[2, 4]]
            @test ta′            == collapse(ta, Minute(1), last)
        end
        let  # second
            ts = [
                DateTime(2018, 1, 2, 12, 0, 0),
                DateTime(2018, 1, 2, 12, 0, 0, 30),
                DateTime(2018, 1, 2, 13, 0, 0),
                DateTime(2018, 1, 2, 13, 0, 0, 30),
            ]
            ta = TimeArray(ts, 1:length(ts))
            ta′ = collapse(ta, second, last)
            @test values(ta′)    == [2, 4]
            @test timestamp(ta′) == ts[[2, 4]]
            @test ta′            == collapse(ta, Second(1), last)
        end
    end

    # https://github.com/JuliaStats/TimeSeries.jl/pull/397
    @testset "Array of String" begin
        A = string.(Char.(rand(97:97+25, size(cl))))
        ts = timestamp(cl)
        ta = TimeArray(ts, A)

        let
            ta = collapse(ta, week, first)

            @test values(ta)[2]    == A[6]
            @test timestamp(ta)[2] == ts[6]
        end
    end

    @testset "type promotion" begin
        ts = [
            DateTime(2018, 1, 2),
            DateTime(2018, 1, 3),
            DateTime(2019, 1, 5),
            DateTime(2019, 2, 6),
        ]
        ta = TimeArray(ts, 1:length(ts))
        ta′ = collapse(ta, month, x -> Date(last(x)), last)

        @test ta  isa TimeArray{Int,1,DateTime,A} where A
        @test ta′ isa TimeArray{Int,1,Date,A} where A

        ta = TimeArray(ts, zeros(4, 10))
        ta′ = collapse(ta, month, x -> Date(last(x)), x -> Int(last(x)))

        @test ta  isa TimeArray{Float64,2,DateTime,A} where A
        @test ta′ isa TimeArray{Int,2,Date,A} where A
    end

    @testset "Period supports" begin
        ts = [
            Date(2018, 1, 2),
            Date(2018, 1, 3),
            Date(2019, 1, 5),
            Date(2019, 2, 6),
        ]
        ta = TimeArray(ts, 1:length(ts))
        ta′ = collapse(ta, Month(2), last)

        @test timestamp(ta′) == [Date(2018, 1, 3), Date(2019, 2, 6)]
        @test values(ta′)    == [2, 4]
    end
end


@testset "merge works correctly" begin
    cl1  = cl[1:3]
    op1  = cl[2:4]
    aapl = tail(AAPL)
    ba   = tail(BA)

    @testset "takes colnames kwarg correctly" begin
        @test colnames(merge(cl, ohlc[:High, :Low], colnames = [:a, :b, :c])) == [:a, :b, :c]
        @test colnames(merge(cl, op, colnames = [:a, :b]))                    == [:a, :b]
        @test_throws ArgumentError merge(cl, op, colnames = [:a])
        @test_throws ArgumentError merge(cl, op, colnames = [:a, :b, :c])

        for mode ∈ [:inner, :left, :right, :outer]
            @test colnames(merge(cl, ohlc[:High, :Low], method = mode, colnames = [:a, :b, :c])) == [:a, :b, :c]
            @test colnames(merge(cl, op, method = mode, colnames = [:a, :b])) == [:a, :b]
            @test_throws ArgumentError merge(cl, op, method = mode, colnames = [:a])
            @test_throws ArgumentError merge(cl, op, method = mode, colnames = [:a, :b, :c])
        end

        # issue #475
        @test colnames(merge(cl, cl, cl, colnames = [:a, :b, :c])) == [:a, :b, :c]
    end

    @testset "returns correct alignment with Dates and values" begin
        @test values(merge(cl, op))     == values(merge(cl, op, method = :inner))
        @test values(merge(cl,op))[2,1] == values(cl)[2,1]
        @test values(merge(cl,op))[2,2] == values(op)[2,1]
    end

    @testset "aligns with disparate sized objects" begin
        @test values(merge(cl, op[2:5]))[1,1]  == values(cl)[2,1]
        @test values(merge(cl, op[2:5]))[1,2]  == values(op)[2,1]
        @test timestamp(merge(cl, op[2:5]))[1] == Date(2000,1,4)
        @test length(merge(cl, op[2:5]))       == 4

        @test length(merge(cl1, op1, method = :inner))      == 2
        @test values(merge(cl1, op1, method = :inner))[2,1] == values(cl1)[3,1]
        @test values(merge(cl1, op1, method = :inner))[2,2] == values(op1)[2,1]

        @test length(merge(cl1, op1, method = :left))      == 3
        @test values(merge(cl1, op1, method = :left))[2,1] == values(cl1)[2,1]
        @test values(merge(cl1, op1, method = :left))[2,2] == values(op1)[1,1]
        @test isnan(values(merge(cl1, op1, method = :left))[1,2])

        @test length(merge(cl1, op1, method = :right))      == 3
        @test values(merge(cl1, op1, method = :right))[2,1] == values(cl1)[3,1]
        @test values(merge(cl1, op1, method = :right))[2,2] == values(op1)[2,1]
        @test isnan(values(merge(cl1, op1, method = :right))[3,1])

        @test length(merge(cl1, op1, method = :outer))      == 4
        @test values(merge(cl1, op1, method = :outer))[2,1] == values(cl1)[2,1]
        @test values(merge(cl1, op1, method = :outer))[2,2] == values(op1)[1,1]
        @test isnan(values(merge(cl1, op1, method = :outer))[1,2])
        @test isnan(values(merge(cl1, op1, method = :outer))[4,1])
    end

    @testset "column names match the correct values" begin
        @test colnames(merge(cl, op[2:5])) == [:Close, :Open]
        @test colnames(merge(op[2:5], cl)) == [:Open, :Close]

        @test colnames(merge(cl, op[2:5], method = :inner)) == [:Close, :Open]
        @test colnames(merge(op[2:5], cl, method = :inner)) == [:Open, :Close]

        @test colnames(merge(cl, op[2:5], method = :left))  == [:Close, :Open]
        @test colnames(merge(op[2:5], cl, method = :left))  == [:Open, :Close]

        @test colnames(merge(cl, op[2:5], method = :right)) == [:Close, :Open]
        @test colnames(merge(op[2:5], cl, method = :right)) == [:Open, :Close]

        @test colnames(merge(cl, op[2:5], method = :outer)) == [:Close, :Open]
        @test colnames(merge(op[2:5], cl, method = :outer)) == [:Open, :Close]
    end

    @testset "unknown method" begin
        @test_throws ArgumentError merge(cl, op, method = :unknown)
    end

    @testset "custom missing values" begin
        ts1 = TimeArray([Date(2018, 1, 1), Date(2018, 1, 2)], [1, 2])
        ts2 = TimeArray([Date(2018, 1, 2), Date(2018, 1, 3)], [3, 4])

        m1 = merge(ts1, ts2, method =  :left, padvalue = 0)
        @test timestamp(m1) == [Date(2018, 1, 1), Date(2018, 1, 2)]
        @test values(m1)    == [1 0; 2 3]

        m2 = merge(ts1, ts2, method = :right, padvalue = 0)
        @test timestamp(m2) == [Date(2018, 1, 2), Date(2018, 1, 3)]
        @test values(m2)    == [2 3; 0 4]

        m3 = merge(ts1, ts2, method = :outer, padvalue = 0)
        @test timestamp(m3) == [Date(2018, 1, 1), Date(2018, 1, 2), Date(2018, 1, 3)]
        @test values(m3)    == [1 0; 2 3; 0 4]
    end

    @testset "vararg input" begin
        ta1 = merge(op, ohlc, cl)
        ta2 = merge(merge(op, ohlc), cl)

        @test timestamp(ta1) == timestamp(ta2)
        @test values(ta1)    == values(ta2)

        # test keyword arguments passing
        ta1 = merge(op, ohlc, cl, method = :outer)
        ta2 = merge(merge(op, ohlc, method = :outer), cl, method = :outer)

        @test timestamp(ta1) == timestamp(ta2)
        @test values(ta1)    == values(ta2)
    end
end


@testset "hcat" begin
    let ta = [cl op cl]
        @test meta(ta)             == meta(cl)
        @test length(colnames(ta)) == 3
        @test colnames(ta)[1]      != colnames(ta)[3]
        @test colnames(ta)[1]      == :Close
        @test colnames(ta)[2]      == :Open
        @test values(ta)           == [values(cl) values(op) values(cl)]
    end

    let ta = [cl ohlc]
        @test meta(ta)             == meta(ta)
        @test length(colnames(ta)) == 5
        @test colnames(ta)[1]      == :Close
        @test colnames(ta)[1]      != colnames(ta)[end]
        @test values(ta)           == [values(cl) values(ohlc)]
    end

    @test_throws DimensionMismatch [cl[1:3] cl]
end


@testset "vcat works correctly" begin
    @testset "concatenates time series correctly in 1D" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], [:Number])
        b = TimeArray([Date(2015, 12, 01)], [17], [:Number])
        c = vcat(a, b)

        @test length(c)   == (length(a) + length(b))
        @test colnames(c) == colnames(a)
        @test colnames(c) == colnames(b)
        @test values(c)   == [15, 16, 17]
    end

    @testset "concatenates time series correctly in 2D" begin
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], [:Number1, :Number2])
        b = TimeArray([Date(2015, 12, 01)], [18 18], [:Number1, :Number2])
        c = vcat(a, b)

        @test length(c)   == length(a) + length(b)
        @test colnames(c) == colnames(a)
        @test colnames(c) == colnames(b)
        @test values(c)   == [[15 16]; [17 18]; [19 20]; [18 18]]
    end

    @testset "rejects when column names do not match" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], [:foo])
        b = TimeArray([Date(2015, 12, 01)], [17], [:bar])

        @test_throws ArgumentError vcat(a, b)
    end

    @testset "rejects when metas do not match" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], [:A], :FirstMeta)
        b = TimeArray([Date(2015, 12, 01)], [17], [:A], :SecondMeta)

        @test_throws ArgumentError vcat(a, b)
    end

    @testset "duplicated timestamps order" begin
        a = TimeArray([Date(2015, 10, 1), Date(2015, 10, 2), Date(2015, 11, 1)], [15, 16, 17])
        b = TimeArray([Date(2015, 10, 2), Date(2015, 11, 1)], [18, 19])

        ts = [Date(2015, 10, 1),
              Date(2015, 10, 2), Date(2015, 10, 2),
              Date(2015, 11, 1), Date(2015, 11, 1)]
        ta = vcat(a, b)
        @test timestamp(ta) == ts
        @test values(ta)    == [15, 16, 18, 17, 19]
    end

    @testset "still works when dates are mixed" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 17])
        b = TimeArray([Date(2015, 11, 01)], [16])
        c = vcat(a, b)

        @test length(c)   == length(a) + length(b)
        @test colnames(c) == colnames(a)
        @test colnames(c) == colnames(b)
        @test values(c)   == [15, 16, 17]
        @test issorted(timestamp(c))
    end
end


@testset "map works correctly" begin
    @testset "works on both time stamps and 1D values" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], [:A], :Something)
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), values .- 1), a)

        @test length(b)                   == length(a)
        @test colnames(b)                 == colnames(a)
        @test Dates.year(timestamp(b)[1]) == Dates.year(timestamp(a)[1]) + 1
        @test values(b)[1]                == values(a)[1] - 1
        @test meta(b)                     == meta(a)
    end

    @testset "works on both time stamps and 2D values" begin
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], [:A, :B])
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), [values[1] + 2, values[2] - 1]), a)

        @test length(b)                   == length(a)
        @test colnames(b)                 == colnames(a)
        @test Dates.year(timestamp(b)[1]) == Dates.year(timestamp(a)[1]) + 1
        @test values(b)[1, 1]             == values(a)[1, 1] + 2
        @test values(b)[1, 2]             == values(a)[1, 2] - 1
    end

    @testset "works with order of elements that varies after modifications" begin
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 16], [:A])
        b = map((timestamp, values) -> (timestamp + Dates.Year((timestamp >= Date(2015, 11, 01)) ? -1 : 1), values), a)

        @test length(b) == length(a)
        @test issorted(timestamp(b))
    end

    @testset "map callable object" begin
        (::_TestType)(ts, x) = (ts, x + 42)

        ta = map(_TestType(), cl)
        @test timestamp(ta) == timestamp(cl)
        @test values(ta)    == values(cl) .+ 42
        @test meta(ta)      == meta(cl)
    end
end


end  # @testset "combine"
