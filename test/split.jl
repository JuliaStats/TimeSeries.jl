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
      @fact by(cl,1981, period=year).timestamp[1]   => date(1981,1,2)
      @fact by(cl,2, period=month).timestamp[1]     => date(1980,2,1)
      @fact by(cl,4, period=day).timestamp[1]       => secondday 
      @fact by(cl,5, period=dayofweek).timestamp[1] => secondday
      @fact by(cl,4, period=dayofyear).timestamp[1] => secondday
  end
end

facts("element wrappers") do

  context("type element wrappers isolate elements") do
      @fact isa(timestamp(cl), Array{Date{ISOCalendar},1}) => true
      @fact isa(values(cl), Array{Float64,1})              => true
      @fact isa(values(ohlc), Array{Float64,2})            => true
      @fact isa(colnames(cl), Array{ASCIIString, 1})       => true
  end
end
