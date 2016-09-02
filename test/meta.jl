using TimeSeries, MarketData
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("construction with and without meta field") do

    nometa = TimeArray(cl.timestamp, cl.values, cl.colnames)

    context("default meta field to nothing") do
        @fact nometa.meta --> nothing
    end

    context("allow objects in meta field") do
        @fact mdata.meta --> "Apple"
    end
end

facts("get index operations preserve meta") do

    context("index by integer row") do
        @fact mdata[1].meta --> "Apple"
    end

    context("index by integer range") do
        @fact mdata[1:2].meta --> "Apple"
    end

    context("index by column name") do
        @fact mdata["Close"].meta --> "Apple"
    end

    context("index by date range") do
        @fact mdata[[Date(2000,1,3), Date(2000,1,14)]].meta --> "Apple"
    end
end

facts("split operations preserve meta") do

    context("when") do
        @fact when(mdata, dayofweek, 1).meta --> "Apple"
    end

    context("from") do
        @fact from(mdata, Date(2000,1,1)).meta --> "Apple"
    end
  
    context("to") do
        @fact to(mdata, Date(2000,1,1)).meta --> "Apple"
    end
end

facts("apply operations preserve meta") do

    context("lag") do
        @fact lag(mdata).meta --> "Apple"
    end

    context("lead") do
        @fact lead(mdata).meta --> "Apple"
    end

    context("percentchange") do
        @fact percentchange(mdata).meta --> "Apple"
    end

    context("moving") do
        @fact moving(mdata,mean,10).meta --> "Apple"
    end
     
    context("upto") do
        @fact upto(mdata,sum).meta --> "Apple"
    end
end

facts("combine operations preserve meta") do

    context("merge when both have identical meta") do
        @fact merge(cl, op).meta         --> "AAPL"
        @fact merge(cl, op, :left).meta  --> "AAPL"
        @fact merge(cl, op, :right).meta --> "AAPL"
        @fact merge(cl, op, :outer).meta --> "AAPL"
    end

    context("merged meta field value concatenates when both objects' meta field values are strings") do
        @fact merge(mdata, cl).meta         --> "Apple_AAPL"
        @fact merge(mdata, cl, :left).meta  --> "Apple_AAPL"
        @fact merge(mdata, cl, :right).meta --> "Apple_AAPL"
        @fact merge(mdata, cl, :outer).meta --> "Apple_AAPL"
    end

    context("merge when supplied with meta") do
        @fact merge(mdata, mdata, meta=47).meta         --> 47
        @fact merge(mdata, mdata, :left, meta=47).meta  --> 47
        @fact merge(mdata, mdata, :right, meta=47).meta --> 47
        @fact merge(mdata, mdata, :outer, meta=47).meta --> 47
        @fact merge(mdata, cl, meta=47).meta            --> 47
        @fact merge(mdata, cl, :left, meta=47).meta     --> 47
        @fact merge(mdata, cl, :right, meta=47).meta    --> 47
        @fact merge(mdata, cl, :outer, meta=47).meta    --> 47
    end

    context("merged meta field value for disparate types in meta field defaults to Void") do
        @fact merge(mdata, merge(cl, op, meta=47)).meta         --> Void
        @fact merge(mdata, merge(cl, op, meta=47), :left).meta  --> Void
        @fact merge(mdata, merge(cl, op, meta=47), :right).meta --> Void
        @fact merge(mdata, merge(cl, op, meta=47), :outer).meta --> Void
    end

    context("collapse") do
        @fact collapse(mdata, week, first).meta --> "Apple"
    end
end

facts("basecall operations preserve meta") do

    context("basecall") do
        @fact basecall(mdata, cumsum).meta --> "Apple"
    end
end

facts("mathematical and comparison operations preserve meta") do

    context(".+") do
        @fact (mdata .+ mdata).meta --> "Apple"
        @fact (mdata .+ cl).meta --> Void
    end

    context(".<") do
        @fact (mdata .< mdata).meta --> "Apple"
        @fact (mdata .< cl).meta --> Void
    end
end

facts("readwrite accepts meta argument") do

    context("Apple is present") do
        @fact mdata.meta --> "Apple"
    end
end
