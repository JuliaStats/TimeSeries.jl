using MarketData

facts("utilities") do

  context("findall returns correct row numbers array") do
      @fact cl[findall(cl .> op)].timestamp[1] => secondday
      @fact length(findall(cl .> op))          => 262
  end

  context("findwhen returns correct dates array") do
      @fact findwhen(cl .> op)[1]      => secondday
      @fact length(findwhen(cl .> op)) => 262
  end
end
