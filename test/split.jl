using TimeSeries, MarketData, Base.Dates
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("find methods") do

    context("findall returns correct row numbers array") do
        @fact cl[findall(cl .> op)].timestamp[1] --> Date(2000,1,3)
        @fact length(findall(cl .> op))          --> 244
    end

    context("findwhen returns correct Dates array") do
       @fact findwhen(cl .> op)[2]      --> Date(2000,1,5)
       @fact length(findwhen(cl .> op)) --> 244
    end
end

facts("split date operations") do

    context("from and to correctly subset") do
        @fact length(from(cl, 2001,12,28)) --> 2
        @fact length(to(cl, 2000,1,4))     --> 2
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
