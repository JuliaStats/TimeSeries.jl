using TimeSeries,  MarketData, Base.Dates
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

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

        @fact merge(cl, ohlc["High", "Low"], :inner, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, :inner, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, :inner, colnames=["a"])
        @fact_throws merge(cl, op, :inner, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], :left, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, :left, colnames=["a","b"]).colnames          --> ["a", "b"]
        @fact_throws merge(cl, op, :left, colnames=["a"])
        @fact_throws merge(cl, op, :left, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], :right, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, :right, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, :right, colnames=["a"])
        @fact_throws merge(cl, op, :right, colnames=["a","b","c"])

        @fact merge(cl, ohlc["High", "Low"], :outer, colnames=["a","b","c"]).colnames --> ["a", "b", "c"]
        @fact merge(cl, op, :outer, colnames=["a","b"]).colnames         --> ["a", "b"]
        @fact_throws merge(cl, op, :outer, colnames=["a"])
        @fact_throws merge(cl, op, :outer, colnames=["a","b","c"])
    end
  
    context("returns correct alignment with Dates and values") do
        @fact merge(cl,op).values --> merge(cl,op, :inner).values
        @fact merge(cl,op).values[2,1] --> cl.values[2,1]
        @fact merge(cl,op).values[2,2] --> op.values[2,1]

    end
    
    context("aligns with disparate sized objects") do
        @fact merge(cl, op[2:5]).values[1,1]  --> cl.values[2,1]
        @fact merge(cl, op[2:5]).values[1,2]  --> op.values[2,1]
        @fact merge(cl, op[2:5]).timestamp[1] --> Date(2000,1,4)
        @fact length(merge(cl, op[2:5]))      --> 4

        @fact length(merge(cl1, op1, :inner))    --> 2
        @fact merge(cl1,op1, :inner).values[2,1] --> cl1.values[3,1]
        @fact merge(cl1,op1, :inner).values[2,2] --> op1.values[2,1]

        @fact length(merge(cl1, op1, :left))     --> 3
        @fact merge(cl1,op1, :left).values[1,2]  --> isnan
        @fact merge(cl1,op1, :left).values[2,1]  --> cl1.values[2,1]
        @fact merge(cl1,op1, :left).values[2,2]  --> op1.values[1,1]

        @fact length(merge(cl1, op1, :right))    --> 3
        @fact merge(cl1,op1, :right).values[2,1] --> cl1.values[3,1]
        @fact merge(cl1,op1, :right).values[2,2] --> op1.values[2,1]
        @fact merge(cl1,op1, :right).values[3,1] --> isnan

        @fact length(merge(cl1, op1, :outer))    --> 4
        @fact merge(cl1,op1, :outer).values[1,2] --> isnan
        @fact merge(cl1,op1, :outer).values[2,1] --> cl1.values[2,1]
        @fact merge(cl1,op1, :outer).values[2,2] --> op1.values[1,1]
        @fact merge(cl1,op1, :outer).values[4,1] --> isnan
    end

    context("column names match the correct values") do
        @fact merge(cl, op[2:5]).colnames               --> ["Close", "Open"]
        @fact merge(op[2:5], cl).colnames               --> ["Open", "Close"]

        @fact merge(cl, op[2:5], :inner).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, :inner).colnames  --> ["Open", "Close"]

        @fact merge(cl, op[2:5], :left).colnames   --> ["Close", "Open"]
        @fact merge(op[2:5], cl, :left).colnames   --> ["Open", "Close"]

        @fact merge(cl, op[2:5], :right).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, :right).colnames  --> ["Open", "Close"]

        @fact merge(cl, op[2:5], :outer).colnames  --> ["Close", "Open"]
        @fact merge(op[2:5], cl, :outer).colnames  --> ["Open", "Close"]
    end
end

facts("vcat works correctly") do
    context("concatenates time series correctly in 1D") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 12, 01)], [17], ["Number"])
        c = vcat(a, b)
    
        @fact length(c)  --> length(a) + length(b)
        @fact c.colnames --> a.colnames
        @fact c.colnames --> b.colnames
        @fact c.values   --> [15, 16, 17]
    end
    
    context("concatenates time series correctly in 2D") do
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], ["Number 1", "Number 2"])
        b = TimeArray([Date(2015, 12, 01)], [18 18], ["Number 1", "Number 2"])
        c = vcat(a, b)
    
        @fact length(c)  --> length(a) + length(b)
        @fact c.colnames --> a.colnames
        @fact c.colnames --> b.colnames
        @fact c.values   --> [[15 16]; [17 18]; [19 20]; [18 18]]
    end
  
    context("rejects when column names do not match") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 12, 01)], [17], ["Data does not match number"])
    
        @fact_throws vcat(a, b)
    end
  
    context("rejects when metas do not match") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"], :FirstMeta)
        b = TimeArray([Date(2015, 12, 01)], [17], ["Number"], :SecondMeta)
    
        @fact_throws vcat(a, b)
    end
  
    context("rejects when dates overlap") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"])
        b = TimeArray([Date(2015, 11, 01)], [17], ["Number"])
    
        @fact_throws vcat(a, b)
    end
  
    context("still works when dates are mixed") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 17], ["Number"])
        b = TimeArray([Date(2015, 11, 01)], [16], ["Number"])
        c = vcat(a, b)
    
        @fact length(c)    --> length(a) + length(b)
        @fact c.colnames   --> a.colnames
        @fact c.colnames   --> b.colnames
        @fact c.values     --> [15, 16, 17]
        @fact c.timestamp  --> issorted
    end
end

facts("map works correctly") do
    context("works on both time stamps and 1D values") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16], ["Number"], :Something)
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), values - 1), a)
    
        @fact length(b)                  --> length(a)
        @fact b.colnames                 --> a.colnames
        @fact Dates.year(b.timestamp[1]) --> Dates.year(a.timestamp[1]) + 1
        @fact b.values[1]                --> a.values[1] - 1
        @fact b.meta                     --> a.meta
    end
    
    context("works on both time stamps and 2D values") do
        a = TimeArray([Date(2015, 09, 01), Date(2015, 10, 01), Date(2015, 11, 01)], [[15 16]; [17 18]; [19 20]], ["Number 1", "Number 2"])
        b = map((timestamp, values) -> (timestamp + Dates.Year(1), [values[1] + 2, values[2] - 1]), a)
    
        @fact length(b)                  --> length(a)
        @fact b.colnames                 --> a.colnames
        @fact Dates.year(b.timestamp[1]) --> Dates.year(a.timestamp[1]) + 1
        @fact b.values[1, 1]             --> a.values[1, 1] + 2
        @fact b.values[1, 2]             --> a.values[1, 2] - 1
    end
    
    context("works with order of elements that varies after modifications") do
        a = TimeArray([Date(2015, 10, 01), Date(2015, 12, 01)], [15, 16], ["Number"])
        b = map((timestamp, values) -> (timestamp + Dates.Year((timestamp >= Date(2015, 11, 01)) ? -1 : 1), values), a)
    
        @fact length(b)    --> length(a)
        @fact b.timestamp  --> issorted
    end
end
