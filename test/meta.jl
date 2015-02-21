using MarketData

facts("construction with and without meta field") do

    context("default meta field to Nothing") do
        @pending cl.meta => Void
        @pending cl.meta => Nothing
    end

    context("allow objects in meta field") do
        @fact mdata.meta => "Apple"
    end
end

facts("get index operations preserve meta") do

    context(" ") do
        @pending by(mdata).meta => "Apple"
    end
end
   
facts("split operations preserve meta") do

    context("by") do
        @fact by(mdata, 1, period=dayofweek).meta => "Apple"
    end

    context("from") do
        @fact from(mdata, 2012,1,1).meta => "Apple"
    end
  
    context("to") do
        @fact to(mdata, 2012,1,1).meta => "Apple"
    end
end

facts("apply operations preserve meta") do

    context("lag") do
        @fact lag(mdata).meta => "Apple"
    end

    context("lead") do
        @fact lead(mdata).meta => "Apple"
    end

    context("percentchange") do
        @fact percentchange(mdata).meta => "Apple"
    end

    context("moving") do
        @pending moving(mdata).meta => "Apple"
    end
     
    context("upto") do
        @pending upto(mdata).meta => "Apple"
    end
end

facts("combine operations preserve meta") do

    context("merge when both have identical meta") do
        @fact merge(mdata, mdata).meta => "Apple"
    end

    context("merge when both have different meta") do
        @fact_throws merge(mdata,cl).meta 
    end

    context("collapse") do
        @fact collapse(mdata, last).meta => "Apple"
    end
end

facts("basecall operations preserve meta") do

    context("basecall") do
        @fact basecall(mdata, cumsum).meta => "Apple"
    end
end

facts("mathematical and comparison operations preserve meta") do

    context(".+") do
        @fact (mdata .+ mdata).meta => "Apple"
    end

    context(".<") do
        @fact (mdata .< mdata).meta => "Apple"
    end
end

facts("readwrite accepts meta argument") do

    context("Apple is present") do
        @fact mdata.meta => "Apple"
    end
end
