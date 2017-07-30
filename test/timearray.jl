using Base.Dates
using Base.Test

using MarketData

using TimeSeries


@testset "timearray" begin


@testset "field extraction methods work" begin
    @testset "timestamp, values, colnames and meta" begin
        @test typeof(timestamp(cl)) == Array{Date,1}
        @test typeof(values(cl))    == Array{Float64,1}
        @test typeof(colnames(cl))  == Array{String,1}
        @test meta(mdata)           == "Apple"
    end
end


@testset "type constructors allow views" begin
    source_rows = 101:121
    source_cols = 1:size(AAPL.values)[2]
    tstamps = view(AAPL.timestamp, source_rows)
    tvalues = view(AAPL.values, source_rows, source_cols)

    AAPL1 = TimeArray(AAPL.timestamp[source_rows],
                      AAPL.values[source_rows, source_cols],
                      AAPL.colnames, AAPL.meta)

    AAPL2 = TimeArray(tstamps, tvalues, AAPL.colnames, AAPL.meta)

    @testset "match first date" begin
        @test AAPL1[1].timestamp == AAPL2[1].timestamp
    end

    @testset "match first values" begin
        @test AAPL1[1].values == AAPL2[1].values
    end

    @testset "match all values" begin
        @test AAPL1.values == AAPL2.values
    end
end


@testset "type constructors enforce invariants" begin
    mangled_stamp = vcat(cl.timestamp[200:end], cl.timestamp[1:199])
    dupe_stamp    = vcat(cl.timestamp[1:499], cl.timestamp[499])
    dupe_cnames   = rename(AAPL, ["a", "b", "c", "a", "a", "b", "d", "e", "e", "e", "e", "f"])

    @testset "unequal length between values and timestamp fails" begin
        @test_throws(
            DimensionMismatch,
            TimeArray(cl.timestamp, cl.values[2:end], ["Close"]))
    end

    @testset "unequal length between colnames and array width fails" begin
        @test_throws(
            DimensionMismatch,
            TimeArray(cl.timestamp, cl.values, ["Close", "Open"]))
    end

    @testset "duplicate timestamp values fails" begin
        @test_throws(
            ArgumentError,
            TimeArray(dupe_stamp, cl.values, ["Close"]))
    end

    @testset "mangled order of timestamp values fails" begin
        @test_throws(
            ArgumentError,
            TimeArray(mangled_stamp, cl.values, ["Close"]))
    end

    @testset "flipping occurs when needed" begin
        @test TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).timestamp[1] == Date(2000,1,3)
        @test TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).values[1]    == 111.94
    end

    @testset "duplicate column names are enumerated by inner constructor" begin
        @test dupe_cnames.colnames[1]  == "a"
        @test dupe_cnames.colnames[2]  == "b"
        @test dupe_cnames.colnames[3]  == "c"
        @test dupe_cnames.colnames[4]  == "a_1"
        @test dupe_cnames.colnames[5]  == "a_2"
        @test dupe_cnames.colnames[6]  == "b_1"
        @test dupe_cnames.colnames[7]  == "d"
        @test dupe_cnames.colnames[8]  == "e"
        @test dupe_cnames.colnames[9]  == "e_1"
        @test dupe_cnames.colnames[10] == "e_2"
        @test dupe_cnames.colnames[11] == "e_3"
        @test dupe_cnames.colnames[12] == "f"
    end
end


@testset "construction without colnames" begin
    no_colnames_one   = TimeArray(cl.timestamp, cl.values)
    no_colnames_multi = TimeArray(AAPL.timestamp, AAPL.values)

    @testset "default colnames to empty String vector" begin
        @test no_colnames_one.colnames   == String[""]
        @test no_colnames_multi.colnames == String["_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9", "_10", "_11", "_12"]
    end

    @testset "empty colnames forces meta to nothing" begin
        @test no_colnames_one.meta   == nothing
        @test no_colnames_multi.meta == nothing
    end
end


@testset "conversion methods" begin
    @testset "convert works " begin
        @test isa(convert(TimeArray{Float64,1}, (cl.>op)), TimeArray{Float64,1})                == true
        @test isa(convert(TimeArray{Float64,2}, (merge(cl.<op, cl.>op))), TimeArray{Float64,2}) == true
        @test isa(convert(cl.>op), TimeArray{Float64,1})                                        == true
        @test isa(convert(merge(cl.<op, cl.>op)), TimeArray{Float64,2})                         == true
    end
end


@testset "index by integer works with both 1d and 2d time array" begin
    @testset "1d time array" begin
        @test cl[1].timestamp == [Date(2000,1,3)]
        @test cl[1].values    == [111.94]
        @test cl[1].colnames  == ["Close"]
        @test cl[1].meta      == "AAPL"
    end

    @testset "2d time array" begin
        @test ohlc[1].timestamp == [Date(2000,1,3)]
        @test ohlc[1].values    == [104.88 112.5 101.69 111.94]
        @test ohlc[1].colnames  == ["Open", "High", "Low","Close"]
        @test ohlc[1].meta      == "AAPL"
    end
end


@testset "ordered collection methods" begin
    @testset "iterator protocol is valid" begin
        @test !isempty(op)
        @test isempty(op[op .< 0])
        @test start(op)              == 1
        @test next(op, 1)            == ((op.timestamp[1], op.values[1,:]), 2)
        @test done(op, length(op)+1) == true
    end

    @testset "end keyword returns correct index" begin
        @test ohlc[end].timestamp[1] == ohlc.timestamp[end]
    end

    @testset "getindex on single Int and Date" begin
        @test ohlc[1].timestamp              == [Date(2000,1,3)]
        @test ohlc[Date(2000,1,3)].timestamp == [Date(2000,1,3)]
    end

    @testset "getindex on array of Int and Date" begin
        @test ohlc[[1,10]].timestamp                           == [Date(2000,1,3), Date(2000,1,14)]
        @test ohlc[[Date(2000,1,3),Date(2000,1,14)]].timestamp == [Date(2000,1,3), Date(2000,1,14)]
    end

    @testset "getindex on range of Int and Date" begin
        @test ohlc[1:2].timestamp                                  == [Date(2000,1,3), Date(2000,1,4)]
        @test ohlc[1:2:4].timestamp                                == [Date(2000,1,3), Date(2000,1,5)]
        @test ohlc[Int8(1):Int8(2):Int8(4)].timestamp              == [Date(2000,1,3), Date(2000,1,5)]
        @test ohlc[Date(2000,1,3):Day(1):Date(2000,1,4)].timestamp == [Date(2000,1,3), Date(2000,1,4)]
    end

    @testset "getindex on range of DateTime when only Date is in timestamp" begin
        @test_throws(
            MethodError,
            ohlc[DateTime(2000,1,3,0,0,0)])
        @test_throws(
            MethodError,
            ohlc[[DateTime(2000,1,3,0,0,0),DateTime(2000,1,14,0,0,0)]])
        @test_throws(
            MethodError,
            ohlc[DateTime(2000,1,3,0,0,0):Day(1):DateTime(2000,1,4,0,0,0)])
    end

    @testset "getindex on range of Date" begin
        @test length(cl[Date(2000,1,1):Date(2001,12,31)]) == 500
    end

    @testset "getindex on single column name" begin
        @test size(ohlc["Open"].values, 2)                                        == 1
        @test size(ohlc["Open"][Date(2000,1,3):Day(1):Date(2000,1,14)].values, 1) == 10
    end

    @testset "getindex on multiple column name" begin
        @test ohlc["Open", "Close"].values[1]   == 104.88
        @test ohlc["Open", "Close"].values[2]   == 108.25
        @test ohlc["Open", "Close"].values[501] == 111.94
    end

    @testset "getindex on 1d returns 1d object" begin
        @test isa(cl[1], TimeArray{Float64,1})   == true
        @test isa(cl[1:2], TimeArray{Float64,1}) == true
    end

    @testset "getindex on a 1d Boolean TimeArray returns appropriate rows" begin
        @test ohlc[op .> cl][2].values             == ohlc[4].values
        @test ohlc[op[300:end] .> cl][2].timestamp == ohlc[303].timestamp
        # MethodError, Bool must be 1D-TimeArray
        @test_throws MethodError ohlc[merge(op.>cl, op.<cl)]
    end
end


@testset "show methods don't throw errors" begin
    show(ohlc)
    show(ohlc[1:4])
    show(ohlc[1:0])
    show(lag(cl[1:2], padding=true))
end


end  # @testset "timearray"
