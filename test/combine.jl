using MarketData

facts("collapse operations") do

  context("collapse squishes correctly") do
      @fact collapse(cl, last).values[1]                  => 106.52
      @fact collapse(cl, last).timestamp[1]               => secondday
      @fact collapse(cl, last, period=month).values[1]    => 114.16
      @fact collapse(cl, last, period=month).timestamp[1] => date(1980,1,31)
  end
end

