using TimeSeries, MarketData
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("update method works") do

    context("able to change column names") do
        @fact 1 --> 2
    end

    context("able to change meta field") do
        @fact 1 --> 2
    end

    context("able to append observation") do
        @fact 1 --> 2
    end

    context("able to prepend observation") do
        @fact 1 --> 2
    end

    context("able to add observation inside existing TimeArray") do
        @fact 1 --> 2
    end
end
