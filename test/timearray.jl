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

    @testset "Base.eachindex" begin
        @test collect(eachindex(cl))   == collect(1:length(cl))
        @test collect(eachindex(ohlc)) == collect(1:length(ohlc))
    end
end


@testset "Base.size" begin
    @test size(ohlc) == (500, 4)
    @test size(ohlc, 1) == 500
    @test size(ohlc, 2) == 4

    @test size(cl) == (500,)
    @test size(cl, 1) == 500
    @test size(cl, 2) == 1
end


@testset "show methods don't throw errors" begin
    let str = sprint(show, cl)
        out = """500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ 111.94 │
│ 2000-01-04 │ 102.5  │
│ 2000-01-05 │ 104.0  │
│ 2000-01-06 │ 95.0   │
│ 2000-01-07 │ 99.5   │
│ 2000-01-10 │ 97.75  │
│ 2000-01-11 │ 92.75  │
│ 2000-01-12 │ 87.19  │
│ 2000-01-13 │ 96.75  │
   ⋮
│ 2001-12-19 │ 21.62  │
│ 2001-12-20 │ 20.67  │
│ 2001-12-21 │ 21.0   │
│ 2001-12-24 │ 21.36  │
│ 2001-12-26 │ 21.49  │
│ 2001-12-27 │ 22.07  │
│ 2001-12-28 │ 22.43  │
│ 2001-12-31 │ 21.9   │"""
        @test str == out
    end

    let str = sprint(show, ohlc)
        out = """500x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31
│            │ Open   │ High   │ Low    │ Close  │
├────────────┼────────┼────────┼────────┼────────┤
│ 2000-01-03 │ 104.88 │ 112.5  │ 101.69 │ 111.94 │
│ 2000-01-04 │ 108.25 │ 110.62 │ 101.19 │ 102.5  │
│ 2000-01-05 │ 103.75 │ 110.56 │ 103.0  │ 104.0  │
│ 2000-01-06 │ 106.12 │ 107.0  │ 95.0   │ 95.0   │
│ 2000-01-07 │ 96.5   │ 101.0  │ 95.5   │ 99.5   │
│ 2000-01-10 │ 102.0  │ 102.25 │ 94.75  │ 97.75  │
│ 2000-01-11 │ 95.94  │ 99.38  │ 90.5   │ 92.75  │
│ 2000-01-12 │ 95.0   │ 95.5   │ 86.5   │ 87.19  │
│ 2000-01-13 │ 94.48  │ 98.75  │ 92.5   │ 96.75  │
   ⋮
│ 2001-12-19 │ 20.58  │ 21.68  │ 20.47  │ 21.62  │
│ 2001-12-20 │ 21.4   │ 21.47  │ 20.62  │ 20.67  │
│ 2001-12-21 │ 21.01  │ 21.54  │ 20.8   │ 21.0   │
│ 2001-12-24 │ 20.9   │ 21.45  │ 20.9   │ 21.36  │
│ 2001-12-26 │ 21.35  │ 22.3   │ 21.14  │ 21.49  │
│ 2001-12-27 │ 21.58  │ 22.25  │ 21.58  │ 22.07  │
│ 2001-12-28 │ 21.97  │ 23.0   │ 21.96  │ 22.43  │
│ 2001-12-31 │ 22.51  │ 22.66  │ 21.83  │ 21.9   │"""
        @test str == out
    end

    let str = sprint(show, AAPL)
        out = """8336x12 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 1980-12-12 to 2013-12-31
│            │ Open   │ High   │ Low    │ Close  │ Volume    │ Ex-Dividend │
├────────────┼────────┼────────┼────────┼────────┼───────────┼─────────────┤
│ 1980-12-12 │ 28.75  │ 28.88  │ 28.75  │ 28.75  │ 2.0939e6  │ 0.0         │
│ 1980-12-15 │ 27.38  │ 27.38  │ 27.25  │ 27.25  │ 785200.0  │ 0.0         │
│ 1980-12-16 │ 25.38  │ 25.38  │ 25.25  │ 25.25  │ 472000.0  │ 0.0         │
│ 1980-12-17 │ 25.88  │ 26.0   │ 25.88  │ 25.88  │ 385900.0  │ 0.0         │
│ 1980-12-18 │ 26.62  │ 26.75  │ 26.62  │ 26.62  │ 327900.0  │ 0.0         │
│ 1980-12-19 │ 28.25  │ 28.38  │ 28.25  │ 28.25  │ 217100.0  │ 0.0         │
│ 1980-12-22 │ 29.62  │ 29.75  │ 29.62  │ 29.62  │ 166800.0  │ 0.0         │
│ 1980-12-23 │ 30.88  │ 31.0   │ 30.88  │ 30.88  │ 209600.0  │ 0.0         │
│ 1980-12-24 │ 32.5   │ 32.62  │ 32.5   │ 32.5   │ 214300.0  │ 0.0         │
   ⋮
│ 2013-12-19 │ 549.5  │ 550.0  │ 543.73 │ 544.46 │ 1.14396e7 │ 0.0         │
│ 2013-12-20 │ 545.43 │ 551.61 │ 544.82 │ 549.02 │ 1.55862e7 │ 0.0         │
│ 2013-12-23 │ 568.0  │ 570.72 │ 562.76 │ 570.09 │ 1.79038e7 │ 0.0         │
│ 2013-12-24 │ 569.89 │ 571.88 │ 566.03 │ 567.67 │ 5.9841e6  │ 0.0         │
│ 2013-12-26 │ 568.1  │ 569.5  │ 563.38 │ 563.9  │ 7.286e6   │ 0.0         │
│ 2013-12-27 │ 563.82 │ 564.41 │ 559.5  │ 560.09 │ 8.0673e6  │ 0.0         │
│ 2013-12-30 │ 557.46 │ 560.09 │ 552.32 │ 554.52 │ 9.0582e6  │ 0.0         │
│ 2013-12-31 │ 554.17 │ 561.28 │ 554.0  │ 561.02 │ 7.9673e6  │ 0.0         │

│            │ Split Ratio │ Adj. Open │ Adj. High │ Adj. Low │ Adj. Close │
├────────────┼─────────────┼───────────┼───────────┼──────────┼────────────┤
│ 1980-12-12 │ 1.0         │ 3.3766    │ 3.3919    │ 3.3766   │ 3.3766     │
│ 1980-12-15 │ 1.0         │ 3.2157    │ 3.2157    │ 3.2004   │ 3.2004     │
│ 1980-12-16 │ 1.0         │ 2.9808    │ 2.9808    │ 2.9655   │ 2.9655     │
│ 1980-12-17 │ 1.0         │ 3.0395    │ 3.0536    │ 3.0395   │ 3.0395     │
│ 1980-12-18 │ 1.0         │ 3.1264    │ 3.1417    │ 3.1264   │ 3.1264     │
│ 1980-12-19 │ 1.0         │ 3.3179    │ 3.3331    │ 3.3179   │ 3.3179     │
│ 1980-12-22 │ 1.0         │ 3.4788    │ 3.494     │ 3.4788   │ 3.4788     │
│ 1980-12-23 │ 1.0         │ 3.6267    │ 3.6408    │ 3.6267   │ 3.6267     │
│ 1980-12-24 │ 1.0         │ 3.817     │ 3.8311    │ 3.817    │ 3.817      │
   ⋮
│ 2013-12-19 │ 1.0         │ 546.2492  │ 546.7463  │ 540.5133 │ 541.239    │
│ 2013-12-20 │ 1.0         │ 542.2033  │ 548.3467  │ 541.5969 │ 545.7721   │
│ 2013-12-23 │ 1.0         │ 564.6398  │ 567.3437  │ 559.4308 │ 566.7174   │
│ 2013-12-24 │ 1.0         │ 566.5186  │ 568.4968  │ 562.6814 │ 564.3117   │
│ 2013-12-26 │ 1.0         │ 564.7392  │ 566.1309  │ 560.0471 │ 560.564    │
│ 2013-12-27 │ 1.0         │ 560.4845  │ 561.071   │ 556.1901 │ 556.7766   │
│ 2013-12-30 │ 1.0         │ 554.1621  │ 556.7766  │ 549.0525 │ 551.2395   │
│ 2013-12-31 │ 1.0         │ 550.8916  │ 557.9595  │ 550.7226 │ 557.7011   │"""
        @test str == out
    end

    let str = sprint(show, ohlc[1:4])
        out = """4x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2000-01-06
│            │ Open   │ High   │ Low    │ Close  │
├────────────┼────────┼────────┼────────┼────────┤
│ 2000-01-03 │ 104.88 │ 112.5  │ 101.69 │ 111.94 │
│ 2000-01-04 │ 108.25 │ 110.62 │ 101.19 │ 102.5  │
│ 2000-01-05 │ 103.75 │ 110.56 │ 103.0  │ 104.0  │
│ 2000-01-06 │ 106.12 │ 107.0  │ 95.0   │ 95.0   │"""
        @test str == out
    end

    let str = sprint(show, ohlc[1:0])
        @test str == "0x4 TimeSeries.TimeArray{Float64,2,Date,Array{Float64,2}}"
    end

    let str = sprint(show, lag(cl[1:2], padding=true))
        out = """2x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-04
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ NaN    │
│ 2000-01-04 │ 111.94 │"""
        @test str == out
    end
end  # @testset "show methods don't throw errors"


end  # @testset "timearray"
