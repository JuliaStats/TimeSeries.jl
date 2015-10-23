using TimeSeries,  MarketData, Base.Dates

facts("collapse operations") do

    context("collapse squishes correctly") do
        @fact collapse(cl, last).values[1]                  --> 99.50
        @fact collapse(cl, last).timestamp[1]               --> Date(2000,1,7)
        @fact collapse(cl, last, period=month).values[1]    --> 103.75
        @fact collapse(cl, last, period=month).timestamp[1] --> Date(2000,1,31)
    end
end

facts("merge works correctly") do

    cl1 = cl[1:3]
    op1 = cl[2:4]

    context("takes colnames kwarg correctly") do
        @fact merge(cl, ohlc["High", "Low"], colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, colnames=["a","b"]).colnames                      --> ["a", "b"]
        @fact_throws merge(cl, op, colnames=["a"])
        @fact_throws merge(cl, op, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], Val{:inner}, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, Val{:inner}, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, Val{:inner}, colnames=["a"])
        @fact_throws merge(cl, op, Val{:inner}, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], Val{:left}, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, Val{:left}, colnames=["a","b"]).colnames          --> ["a", "b"]
        @fact_throws merge(cl, op, Val{:left}, colnames=["a"])
        @fact_throws merge(cl, op, Val{:left}, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], Val{:right}, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, Val{:right}, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, Val{:right}, colnames=["a"])
        @fact_throws merge(cl, op, Val{:right}, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], Val{:outer}, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, Val{:outer}, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, Val{:outer}, colnames=["a"])
        @fact_throws merge(cl, op, Val{:outer}, colnames=["a","b","c"])
    end
  
    context("returns correct alignment with Dates and values") do
        @fact merge(cl,op).values --> merge(cl,op, Val{:inner}).values
        @fact merge(cl,op).values[2,1] --> cl.values[2,1]
        @fact merge(cl,op).values[2,2] --> op.values[2,1]

    end
    
    context("aligns with disparate sized objects") do
        @fact merge(cl, op[2:5]).values[1,1]  --> cl.values[2,1]
        @fact merge(cl, op[2:5]).values[1,2]  --> op.values[2,1]
        @fact merge(cl, op[2:5]).timestamp[1] --> Date(2000,1,4)
        @fact length(merge(cl, op[2:5]))      --> 4

        @fact length(merge(cl1, op1, Val{:inner}))    --> 2
        @fact merge(cl1,op1, Val{:inner}).values[2,1] --> cl1.values[3,1]
        @fact merge(cl1,op1, Val{:inner}).values[2,2] --> op1.values[2,1]

        @fact length(merge(cl1, op1, Val{:left}))     --> 3
        @fact merge(cl1,op1, Val{:left}).values[1,2]  --> isnan 
        @fact merge(cl1,op1, Val{:left}).values[2,1]  --> cl1.values[2,1]
        @fact merge(cl1,op1, Val{:left}).values[2,2]  --> op1.values[1,1]

        @fact length(merge(cl1, op1, Val{:right}))    --> 3
        @fact merge(cl1,op1, Val{:right}).values[2,1] --> cl1.values[3,1]
        @fact merge(cl1,op1, Val{:right}).values[2,2] --> op1.values[2,1]
        @fact merge(cl1,op1, Val{:right}).values[3,1] --> isnan 

        @fact length(merge(cl1, op1, Val{:outer}))    --> 4
        @fact merge(cl1,op1, Val{:outer}).values[1,2] --> isnan 
        @fact merge(cl1,op1, Val{:outer}).values[2,1] --> cl1.values[2,1]
        @fact merge(cl1,op1, Val{:outer}).values[2,2] --> op1.values[1,1]
        @fact merge(cl1,op1, Val{:outer}).values[4,1] --> isnan 
    end

    context("column names match the correct values") do
        @fact merge(cl, op[2:5]).colnames               --> ["Close", "Open"]
        @fact merge(op[2:5], cl).colnames               --> ["Open", "Close"]

        @fact merge(cl, op[2:5], Val{:inner}).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, Val{:inner}).colnames  --> ["Open", "Close"]

        @fact merge(cl, op[2:5], Val{:left}).colnames   --> ["Close", "Open"]
        @fact merge(op[2:5], cl, Val{:left}).colnames   --> ["Open", "Close"]

        @fact merge(cl, op[2:5], Val{:right}).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, Val{:right}).colnames  --> ["Open", "Close"]

        @fact merge(cl, op[2:5], Val{:outer}).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, Val{:outer}).colnames  --> ["Open", "Close"]
    end
end
