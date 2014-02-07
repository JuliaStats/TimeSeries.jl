using MarketData

facts("timestamp operations") do

  context("collapse squishes correctly") do
      @fact collapse(cl, last).values[1]                  => 106.52
      @fact collapse(cl, last).timestamp[1]               => secondday
      @fact collapse(cl, last, period=month).values[1]    => 114.16
      @fact collapse(cl, last, period=month).timestamp[1] => date(1980,1,31)
  end

  context("from and to correctly subset") do
      @fact length(from(cl, 1981,12,30)) => 2
      @fact length(to(cl, 1980,1,4))     => 2
  end

  context("bydate methods correctly subset") do
      @fact byyear(cl,1981).timestamp[1] => date(1981,1,2)
      @fact bymonth(cl,2).timestamp[1]   => date(1980,2,1)
      @fact byday(cl,4).timestamp[1]     => secondday 
      @fact bydow(cl,5).timestamp[1]     => secondday
      @fact bydoy(cl,4).timestamp[1]     => secondday
  end
end
