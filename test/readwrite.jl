using MarketData

facts("readwrite parses csv file correctly") do

  context("1d values array works") do
      @fact typeof(cl.values) => Array{Float64,1}
  end

  context("2d values array works") do
      @fact typeof(ohlc.values) => Array{Float64,2}
  end

  context("Specifying DateTime string format for reading") do
      # incorrect reading without format specification
      ta0 = readtimearray("test/read_example_txns.csv")
      @fact ta0.timestamp[1] => not(DateTime(1961,12,31))
      
      ta = readtimearray("test/read_example_txns.csv",
                         dtformat="yyyy-mm-dd HH:MM:SS")
      @fact length(ta) => 5
      @fact size(ta.values) => (5,6)
      @fact ta.timestamp[4] => DateTime(1967,2,15,16)
      @fact ta["Txn.Avg.Cost"].values[5] => roughly(84.13)
  end

  context("timestamp parses to correct type") do
      @fact typeof(cl.timestamp)    => Vector{Date}
      @fact typeof(sdata.timestamp) => Vector{DateTime}
  end

  context("readtimearray accepts meta field") do
      @pending mdata => "construct mdata from csv vs reconstructing a Time Array" 
  end
end
