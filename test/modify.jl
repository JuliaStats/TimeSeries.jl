using TimeSeries, MarketData, Base.Dates
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("update method works") do

    new_cls  = update(cl, today(), 111.11)
    new_clv  = update(cl, today(), [111.11])
    new_ohlc = update(ohlc, today(), [111.11, 222.22, 333.33, 444.44])

    context("update a single column time array with single value") do
        @fact last(new_cls.values) --> 111.11
    end

    context("update a single column time array with single value vector") do
        @fact last(new_clv.values) --> 111.11
        @fact_throws update(cl, today(), [111.11, 222.22])
    end

    context("update a multi column time array") do
        #@fact last(new_ohlc).values --> [111.11 222.22 333.33 444.44]
        @fact tail(new_ohlc).values --> [111.11 222.22 333.33 444.44]
        @fact_throws update(ohlc, today(),  [111.11, 222.22, 333.33])
    end

    context("cannot update more than one observation at a time") do
        @fact_throws update(cl, [Date(2002,1,1), Date(2002,1,2)], [111.11, 222,22])
    end

    context("cannot update oldest observations") do
        @fact_throws update(cl, Date(1999,1,1), [111.11])
        @fact_throws update(cl, Date(1999,1,1), 111.11)
    end

    context("cannot update in-between observations") do
        @fact_throws update(cl, Date(2000,1,8), [111.11])
        @fact_throws update(cl, Date(2000,1,8), 111.11)
    end
end

facts("rename method works") do

    re_ohlc = rename(ohlc, ["a","b","c","d"]) 
    re_cl   = rename(cl, ["vector"]) 
    re_cls  = rename(cl, "string") 

    context("change colnames with multi-member vector") do
        @fact colnames(re_ohlc) --> ["a","b","c","d"]
        @fact_throws rename(ohlc, ["a"])
    end

    context("change colnames with single-member vector") do
        @fact colnames(re_cl) --> ["vector"]
        @fact_throws rename(cl, ["a", "b"])
    end

    context("change colnames with string") do
        @fact colnames(re_cls) --> ["string"]
        @fact_throws rename(cl, "string_a", "string_b")
    end
end
