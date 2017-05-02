using Base.Dates, TimeSeries, MarketData
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("field extraction methods work") do

    context("timestamp, values, colnames and meta") do
        @fact typeof(timestamp(cl)) --> Array{Date,1}
        @fact typeof(values(cl))    --> Array{Float64,1}
        @fact typeof(colnames(cl))  --> Array{String,1}
        @fact meta(mdata)           --> "Apple"
    end
end

facts("type constructors enforce invariants") do

    mangled_stamp = vcat(cl.timestamp[200:end], cl.timestamp[1:199])
    dupe_stamp    = vcat(cl.timestamp[1:499], cl.timestamp[499])
    dupe_cnames   = rename(AAPL,  ["a", "b", "c", "a", "a", "b", "d", "e", "e", "e", "e", "f"])

    context("unequal length between values and timestamp fails") do
        @fact_throws TimeArray(cl.timestamp, cl.values[2:end], ["Close"])
    end

    context("unequal length between colnames and array width fails") do
        @fact_throws TimeArray(cl.timestamp, cl.values, ["Close", "Open"])
    end

    context("duplicate timestamp values fails") do
        @fact_throws TimeArray(dupe_stamp, cl.values, ["Close"])
    end

    context("mangled order of timestamp values fails") do
        @fact_throws TimeArray(mangled_stamp, cl.values, ["Close"])
    end

    context("flipping occurs when needed") do
        @fact TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).timestamp[1] --> Date(2000,1,3)
        @fact TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).values[1]    --> 111.94
    end

    context("duplicate column names are enumerated by inner constructor") do
        @fact dupe_cnames.colnames[1]  --> "a"
        @fact dupe_cnames.colnames[2]  --> "b"
        @fact dupe_cnames.colnames[3]  --> "c"
        @fact dupe_cnames.colnames[4]  --> "a_1"
        @fact dupe_cnames.colnames[5]  --> "a_2"
        @fact dupe_cnames.colnames[6]  --> "b_1"
        @fact dupe_cnames.colnames[7]  --> "d"
        @fact dupe_cnames.colnames[8]  --> "e"
        @fact dupe_cnames.colnames[9]  --> "e_1"
        @fact dupe_cnames.colnames[10] --> "e_2"
        @fact dupe_cnames.colnames[11] --> "e_3"
        @fact dupe_cnames.colnames[12] --> "f"
    end
end

facts("construction without colnames") do

    no_colnames_one   = TimeArray(cl.timestamp, cl.values)
    no_colnames_multi = TimeArray(AAPL.timestamp, AAPL.values)

    context("default colnames to empty String vector") do
        @fact no_colnames_one.colnames   --> String[""]
        @fact no_colnames_multi.colnames --> String["_1", "_2", "_3", "_4", "_5", "_6", "_7", "_8", "_9", "_10", "_11", "_12"]
    end

    context("empty colnames forces meta to nothing") do
        @fact no_colnames_one.meta   --> nothing
        @fact no_colnames_multi.meta --> nothing
    end
end

facts("conversion methods") do

    context("convert works ") do
        @fact isa(convert(TimeArray{Float64,1}, (cl.>op)), TimeArray{Float64,1})                --> true
        @fact isa(convert(TimeArray{Float64,2}, (merge(cl.<op, cl.>op))), TimeArray{Float64,2}) --> true
        @fact isa(convert(cl.>op), TimeArray{Float64,1})                                        --> true
        @fact isa(convert(merge(cl.<op, cl.>op)), TimeArray{Float64,2})                         --> true
    end
end

facts("index by integer works with both 1d and 2d time array") do

    context("1d time array") do
        @fact cl[1].timestamp --> [Date(2000,1,3)]
        @fact cl[1].values    --> [111.94]
        @fact cl[1].colnames  --> ["Close"]
        @fact cl[1].meta      --> "AAPL"
    end

    context("2d time array") do
        @fact ohlc[1].timestamp --> [Date(2000,1,3)]
        @fact ohlc[1].values    --> [104.88 112.5 101.69 111.94]
        @fact ohlc[1].colnames  --> ["Open", "High", "Low","Close"]
        @fact ohlc[1].meta      --> "AAPL"
    end
end

facts("ordered collection methods") do

    context("iterator protocol is valid") do
        @fact op                     --> not(isempty)
        @fact op[op .< 0]            --> isempty
        @fact start(op)              --> 1
        @fact next(op, 1)            --> ((op.timestamp[1], op.values[1,:]), 2)
        @fact done(op, length(op)+1) --> true
    end

    context("end keyword returns correct index") do
        @fact ohlc[end].timestamp[1] --> ohlc.timestamp[end]
    end

    context("getindex on single Int and Date") do
        @fact ohlc[1].timestamp              --> [Date(2000,1,3)]
        @fact ohlc[Date(2000,1,3)].timestamp --> [Date(2000,1,3)]
    end

    context("getindex on array of Int and Date") do
        @fact ohlc[[1,10]].timestamp                           --> [Date(2000,1,3), Date(2000,1,14)]
        @fact ohlc[[Date(2000,1,3),Date(2000,1,14)]].timestamp --> [Date(2000,1,3), Date(2000,1,14)]
    end

    context("getindex on range of Int and Date") do
        @fact ohlc[1:2].timestamp                                  --> [Date(2000,1,3), Date(2000,1,4)]
        @fact ohlc[1:2:4].timestamp                                --> [Date(2000,1,3), Date(2000,1,5)]
        @fact ohlc[Date(2000,1,3):Day(1):Date(2000,1,4)].timestamp --> [Date(2000,1,3), Date(2000,1,4)]
    end

    context("getindex on range of DateTime when only Date is in timestamp") do
        @fact_throws ohlc[DateTime(2000,1,3,0,0,0)]
        @fact_throws ohlc[[DateTime(2000,1,3,0,0,0),DateTime(2000,1,14,0,0,0)]]
        @fact_throws ohlc[DateTime(2000,1,3,0,0,0):Day(1):DateTime(2000,1,4,0,0,0)]
    end

    context("getindex on range of Date") do
        @fact length(cl[Date(2000,1,1):Date(2001,12,31)]) --> 500
    end

    context("getindex on single column name") do
        @fact size(ohlc["Open"].values, 2)                                        --> 1
        @fact size(ohlc["Open"][Date(2000,1,3):Day(1):Date(2000,1,14)].values, 1) --> 10
    end

    context("getindex on multiple column name") do
        @fact ohlc["Open", "Close"].values[1]   --> 104.88
        @fact ohlc["Open", "Close"].values[2]   --> 108.25
        @fact ohlc["Open", "Close"].values[501] --> 111.94
    end

    context("getindex on 1d returns 1d object") do
        @fact isa(cl[1], TimeArray{Float64,1})   --> true
        @fact isa(cl[1:2], TimeArray{Float64,1}) --> true
    end

    context("getindex on a 1d Boolean TimeArray returns appropriate rows") do
        @fact ohlc[op .> cl][2].values             --> ohlc[4].values
        @fact ohlc[op[300:end] .> cl][2].timestamp --> ohlc[303].timestamp
        @fact_throws ohlc[merge(op.>cl, op.<cl)] # MethodError, Bool must be 1D-TimeArray
    end

end

facts("show methods don't throw errors") do

    show(ohlc)
    show(ohlc[1:4])
    show(ohlc[1:0])
    show(lag(cl[1:2], padding=true))

end
