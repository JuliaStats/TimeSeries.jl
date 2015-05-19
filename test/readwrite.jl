using MarketData

facts("readwrite parses csv file correctly") do

  context("1d values array works") do
      @fact typeof(cl.values) => Array{Float64,1}
  end

  context("2d values array works") do
      @fact typeof(ohlc.values) => Array{Float64,2}
  end

  context("Specifying DateTime string format for reading") do
      ta = readtimearray(Pkg.dir("TimeSeries/test/data/datetime3.csv"), format="yyyy/mm/dd|HH:MM:SS")
      @fact length(ta) => 5
      @fact size(ta.values) => (5,1)
      @fact ta.timestamp[4] => DateTime(2010,1,4,9,4)
      @fact_throws readtimearray(Pkg.dir("TimeSeries/test/data/datetime3.csv"))
  end

  context("timestamp parses to correct type") do
      @fact typeof(cl.timestamp)        => Vector{Date}
      @fact typeof(datetime1.timestamp) => Vector{DateTime}
  end

  context("readtimearray accepts meta field") do
      @pending mdata => "construct mdata from csv vs reconstructing a Time Array" 
  end
end
