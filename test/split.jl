using TimeSeries, MarketData, Base.Dates
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("find methods") do

    context("find returns correct row numbers array") do
        @fact cl[find(cl .> op)].timestamp[1] --> Date(2000,1,3)
        @fact length(find(cl .> op))          --> 244
    end

    context("findwhen returns correct Dates array") do
       @fact findwhen(cl .> op)[2]      --> Date(2000,1,5)
       @fact length(findwhen(cl .> op)) --> 244
    end
end

facts("split date operations") do

    context("from and to correctly subset non-zero and zero-length time arrays") do 
        @fact length(from(cl, Date(2001,12,28))) --> 2
        @fact length(from(cl, Date(2002,1,1)))   --> 0
        @fact length(from(from(cl, Date(2002,1,1)), Date(2012,1,1))) --> 0 
        
        @fact length(to(cl, Date(2000,1,4)))     --> 2
        @fact length(to(cl, Date(1999,1,4)))     --> 0 
        @fact length(to(to(cl, Date(1999,1,4)), Date(1912,1,1))) --> 0 
    end
        
    context("when method correctly subset") do
        @fact when(cl, day, 4).timestamp[1]              --> Date(2000,1,4) 
        @fact when(cl, dayname, "Friday").timestamp[1]   --> Date(2000,1,7)
        @fact when(cl, week, 5).timestamp[1]             --> Date(2000,1,31)
        @fact when(cl, month, 5).timestamp[1]            --> Date(2000,5,1)
        @fact when(cl, monthname, "June").timestamp[1]   --> Date(2000,6,1)
        @fact when(cl, year, 2001).timestamp[1]          --> Date(2001,1,2)
        @fact when(cl, dayofweek, 1).timestamp[1]        --> Date(2000,1,3)
        # all the days in the nth week of each month
        @fact when(cl, dayofweekofmonth, 5).timestamp[1] --> Date(2000,1,31)
        @fact when(cl, dayofyear, 365).timestamp[1]      --> Date(2001,12,31)
        @fact when(cl, quarterofyear, 4).timestamp[1]    --> Date(2000,10,2)
        @fact when(cl, dayofquarter, 1).timestamp[1]     --> Date(2001,10,1)
    end
end

facts("element wrappers") do

    context("type element wrappers isolate elements") do
        @fact isa(timestamp(cl), Array{Date,1})       --> true
        @fact isa(values(cl), Array{Float64,1})       --> true
        @fact isa(values(ohlc), Array{Float64,2})     --> true
        @fact isa(colnames(cl), Array{UTF8String, 1}) --> true
    end
end

facts("head and tail methods") do

    context("head and tail methods work with default n value on single column TimeArray") do
        @fact length(head(cl))      --> 1
        @fact length(head(cl,1))    --> 1
        @fact head(cl).timestamp[1] --> Date(2000,1,3)
        @fact head(cl).values[1]    --> 111.94
        @fact head(cl).meta         --> "AAPL"

        @fact length(tail(cl))      --> 1
        @fact length(tail(cl,1))    --> 1
        @fact tail(cl).timestamp[1] --> Date(2001,12,31)
        @fact tail(cl).values[1]    --> 21.9
        @fact tail(cl).meta         --> "AAPL"
    end

    context("head and tail methods work with default n value on multi column TimeArray") do
        @fact length(head(ohlc))      --> 1
        @fact length(head(ohlc,1))    --> 1
        @fact head(ohlc).timestamp[1] --> Date(2000,1,3)
        @fact head(ohlc).values       --> [104.88  112.5  101.69  111.94]
        @fact head(ohlc).meta         --> "AAPL"

        @fact length(tail(ohlc))      --> 1
        @fact length(tail(ohlc,1))    --> 1
        @fact tail(ohlc).timestamp[1] --> Date(2001,12,31)
        @fact tail(ohlc).values       --> [22.51  22.66  21.83  21.9]
        @fact tail(ohlc).meta         --> "AAPL"
    end

    context("head and tail methods work with custom periods on single column TimeArray") do
        @fact length(head(cl, 2))   --> 2
        @fact length(head(cl, 500)) --> length(cl)
        @fact length(tail(cl, 2))   --> 2
        @fact length(tail(cl, 500)) --> length(cl)
    end

    context("head and tail methods work with custom periods on multi column TimeArray") do
        @fact length(head(ohlc, 2))   --> 2
        @fact length(head(ohlc, 500)) --> length(ohlc)
        @fact length(tail(ohlc, 2))   --> 2
        @fact length(tail(ohlc, 500)) --> length(ohlc)
    end
end
