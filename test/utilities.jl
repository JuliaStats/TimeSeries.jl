using MarketData

facts("utilities") do

  context("timestamp returns Array{Date{ISOCalendar},1}") do
      @fact isa(timestamp(cl), Array{Date{ISOCalendar},1}) => true
  end

  context("values returns Array{Float64,1}") do
      @fact isa(values(cl), Array{Float64,1}) => true
  end

  context("values returns Array{Float64,2}") do
      @fact isa(values(ohlc), Array{Float64,2}) => true
  end

  context("colnames returns Array{ASCIIString,1}") do
      @fact isa(colnames(cl), Array{ASCIIString, 1}) => true
  end

  context("head returns the first row, or specified rows") do
      @fact size(head(cl).timestamp, 1)    => 1
      @fact size(head(cl, 3).timestamp, 1) => 3
  end

  context("tail returns all but first row, or specified rows") do
      @fact size(tail(cl).timestamp, 1)               => 504
      @fact size(tail(cl, length(cl)-2).timestamp, 1) => 3
  end

  context("findall returns correct row numbers array") do
      @fact cl[findall(cl .> op)].timestamp[1] => secondday
      @fact length(findall(cl .> op))          => 262
  end
end
