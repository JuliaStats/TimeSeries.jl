using MarketData

facts("readwrite parses csv file correctly") do

  context("1-d values array works") do
      @fact typeof(cl.values) => Array{Float64,1}
  end

  context("1-d values array works") do
      @fact typeof(ohlc.values) => Array{Float64,2}
  end

  context("timestamp parses to correct type") do
      @fact typeof(cl.timestamp) => Array{Date,1}
  end
end

