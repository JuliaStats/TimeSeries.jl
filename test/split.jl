using MarketData

facts("find methods") do

  context("findall returns correct row numbers array") do
      @fact cl[findall(cl .> op)].timestamp[1] => secondday
      @fact length(findall(cl .> op))          => 262
  end

  context("findwhen returns correct dates array") do
      @fact findwhen(cl .> op)[1]      => secondday
      @fact length(findwhen(cl .> op)) => 262
  end
end

facts("split date operations") do

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
