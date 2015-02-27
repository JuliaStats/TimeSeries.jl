using MarketData

facts("collapse operations") do

    context("collapse squishes correctly") do
        @fact collapse(cl, last).values[1]                  => 99.50
        @fact collapse(cl, last).timestamp[1]               => Date(2000,1,7)
        @fact collapse(cl, last, period=month).values[1]    => 103.75
        @fact collapse(cl, last, period=month).timestamp[1] => Date(2000,1,31)
    end
end

facts("merge works correctly") do

    context("takes colnames kwarg correctly") do
        @fact merge(cl,ohlc["High", "Low"], col_names=["a","b","c"]).colnames[1] => "a"
        @fact merge(cl,ohlc["High", "Low"], col_names=["a","b","c"]).colnames[2] => "b"
        @fact merge(cl,ohlc["High", "Low"], col_names=["a","b","c"]).colnames[3] => "c"
        @fact merge(cl,op, col_names=["a","b"]).colnames[1]                      => "a"
        @fact merge(cl,op, col_names=["a","b"]).colnames[2]                      => "b"
        @fact merge(cl,op, col_names=["a"]).colnames[1]                          => "Close"
        @fact merge(cl,op, col_names=["a"]).colnames[2]                          => "Open"
        @fact_throws merge(cl,op, col_names=["a","b","c"])
        @fact_throws merge(cl,op, col_names=["a","b","c"])
    end
  
    context("returns correct alignment with Dates and values") do
        @fact merge(cl,op).values[2,1] => cl.values[2,1]
        @fact merge(cl,op).values[2,2] => op.values[2,1]
    end
    
    context("aligns with disparate sized objects") do
        @fact merge(cl, op[2:5]).values[1,1]  => cl.values[2,1]
        @fact merge(cl, op[2:5]).values[1,2]  => op.values[2,1]
        @fact merge(cl, op[2:5]).timestamp[1] => Date(2000,1,4)
        @fact length(merge(cl, op[2:5]))      => 4
    end

    context("column names match the correct values") do
        @fact merge(cl, op[2:5]).colnames[1]  => "Close"
        @fact merge(cl, op[2:5]).colnames[2]  => "Open"
        @fact merge(op[2:5], cl).colnames[1]  => "Open"
        @fact merge(op[2:5], cl).colnames[2]  => "Close"
    end
end
