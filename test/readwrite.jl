using FactCheck
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

using TimeSeries, MarketData

facts("readwrite parses csv file correctly") do

    context("1d values array works") do
        @fact typeof(cl.values) --> Array{Float64,1}
    end

    context("2d values array works") do
        @fact typeof(ohlc.values) --> Array{Float64,2}
    end

    context("Specifying DateTime string format for reading") do
        tm = readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"), format="yyyy/mm/dd|HH:MM:SS")
        @fact length(tm) --> 5
        @fact size(tm.values) --> (5,1)
        @fact tm.timestamp[4] --> DateTime(2010,1,4,9,4)
        @fact_throws readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"))
    end

    context("Input as IOBuffer and specifying DateTime string format for reading") do
        s = "DateTime,Open
2010/1/4|9:01:00,7300
2010/1/4|9:02:00,7316
2010/1/4|9:03:00,7316
2010/1/4|9:04:00,7316
2010/1/4|9:05:00,7316"
        tm = readtimearray(IOBuffer(s), format="yyyy/mm/dd|HH:MM:SS")
        @fact length(tm) --> 5
        @fact size(tm.values) --> (5,1)
        @fact tm.timestamp[4] --> DateTime(2010,1,4,9,4)
    end

    context("timestamp parses to correct type") do
        @fact typeof(cl.timestamp)        --> Vector{Date}
        @fact typeof(datetime1.timestamp) --> Vector{DateTime}
    end

    context("readtimearray accepts meta field") do
        tm = readtimearray(joinpath(dirname(@__FILE__), "data/datetime3.csv"), format="yyyy/mm/dd|HH:MM:SS", meta="foo")
        @fact tm.meta --> "foo"
    end

    context("readtimearray works with arbitrary delimiters") do
        tm = readtimearray(joinpath(dirname(@__FILE__), "data/read_example_delim.csv"), format="dd/mm/yyyy HH:MM", delim=';')
        @fact length(tm) --> 2
        @fact size(tm.values) --> (2,2)
        @fact tm.timestamp[2] --> DateTime(2015,1,1,1,0)
        @fact tm.values[1,1] --> 10.42
    end

    context("writetimearray output can be round-tripped") do
        filename = "$(randstring()).csv"
        uohlc = uniformspace(ohlc)
        writetimearray(uohlc, filename)
        readback = readtimearray(filename)
        @fact uohlc.colnames                         --> readback.colnames
        @fact uohlc.timestamp                        --> readback.timestamp
        @fact isequal(uohlc.values, readback.values) --> true
        rm(filename)
    end

end
