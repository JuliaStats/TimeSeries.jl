using MarketData

facts("readwrite parses csv file correctly") do

  context("1d values array works") do
      @fact typeof(cl.values) => Array{Float64,1}
  end

  context("2d values array works") do
      @fact typeof(ohlc.values) => Array{Float64,2}
  end

  context("timestamp parses to correct type") do
      @fact typeof(cl.timestamp)    => Vector{Date}
      @fact typeof(sdata.timestamp) => Vector{DateTime}
  end

  context("readtimearray accepts meta field") do
      @pending mdata => "construct mdata from csv vs reconstructing a Time Array" 
  end
end
