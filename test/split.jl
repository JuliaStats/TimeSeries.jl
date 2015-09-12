using MarketData

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

    context("bydate methods correctly subset") do
        @fact by(cl,2001, period=year).timestamp[1]   --> Date(2001,1,2)
        @fact by(cl,2, period=month).timestamp[1]     --> Date(2000,2,1)
        @fact by(cl,4, period=day).timestamp[1]       --> Date(2000,1,4) 
        @fact by(cl,5, period=dayofweek).timestamp[1] --> Date(2000,1,7)
        @fact by(cl,4, period=dayofyear).timestamp[1] --> Date(2000,1,4)
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
