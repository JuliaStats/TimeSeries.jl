using TimeSeries, MarketData
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("readwrite parses IO correctly") do

io  = "DateTime,Open
       2010/1/4|9:01:00,7300
       2010/1/4|9:02:00,7316
       2010/1/4|9:03:00,7316
       2010/1/4|9:04:00,7316
       2010/1/4|9:05:00,7316"

tm0 = readtimearray(IOBuffer(io), format="yyyy/mm/dd|HH:MM:SS")

    context("Input as IOBuffer and specifying DateTime string format for reading") do
        @fact length(tm0)      --> 5
        @fact size(tm0.values) --> (5,1)
        @fact tm0.timestamp[4] --> DateTime(2010,1,4,9,4)
    end
end

facts("readwrite parses csv correctly") do

tm1 = readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"), format="yyyy/mm/dd|HH:MM:SS")
tm2 = readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"), format="yyyy/mm/dd|HH:MM:SS", meta="foo")
tm3 = readtimearray(joinpath(dirname(@__FILE__), "data/read_example_delim.csv"), format="dd/mm/yyyy HH:MM", delim=';')

    context("Specifying DateTime string format for reading") do
        @fact length(tm1)      --> 5
        @fact size(tm1.values) --> (5,1)
        @fact tm1.timestamp[4]  --> DateTime(2010,1,4,9,4)
        @fact_throws readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"))
    end

    context("readtimearray accepts meta field") do
        @fact tm2.meta --> "foo"
    end

    context("readtimearray works with arbitrary delimiters") do
        @fact length(tm3)      --> 2
        @fact size(tm3.values) --> (2,2)
        @fact tm3.timestamp[2] --> DateTime(2015,1,1,1,0)
        @fact tm3.values[1,1]  --> 10.42
    end
end

facts("readwrite parses MarketData objects correctly") do

    context("1d values array works") do
        @fact typeof(cl.values) --> Array{Float64,1}
    end

    context("2d values array works") do
        @fact typeof(ohlc.values) --> Array{Float64,2}
    end

    context("timestamp parses to correct type") do
        @fact typeof(cl.timestamp)        --> Vector{Date}
        @fact typeof(datetime1.timestamp) --> Vector{DateTime}
    end
end

facts("writetimearray method works") do
    filename = "$(randstring()).csv"
    uohlc    = uniformspace(ohlc)
    writetimearray(uohlc, filename)
    readback = readtimearray(filename)

    context("writetimearray output can be round-tripped") do
        @fact uohlc.colnames                         --> readback.colnames
        @fact uohlc.timestamp                        --> readback.timestamp
        @fact isequal(uohlc.values, readback.values) --> true
        rm(filename)
    end
end
