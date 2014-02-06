using MarketData

facts("transformations") do

  context("lag takes previous day and timestamps it to next day") do
      @fact lag(cl).values[1]    => roughly(105.22) 
      @fact lag(cl).timestamp[1] => secondday
  end

  context("lag accepts kwarg") do
      @fact lag(cl, period=9).timestamp[1] => tenthday
  end

  context("lead takes next day and timestamps it to current day") do
      @fact lead(cl).values[1]    => roughly(106.52) 
      @fact lead(cl).timestamp[1] => firstday
  end

  context("lead accepts kwarg") do
      @fact lead(cl, period=9).values[1]    => 111.05
      @fact lead(cl, period=9).timestamp[1] => firstday
  end

  context("correct simple return value") do
      @fact percentchange(cl).values[1] => roughly((106.52-105.22)/105.22)
  end

  context("correct log return value") do
      @fact percentchange(cl, method="log").values[1] => roughly(log(106.52) - log(105.22))
  end

  context("moving supplies correct window length") do
#       @fact moving(cl, mean, 10).values[1]    => roughly(sum(cl.values[1:10])/10)
#       @fact moving(cl, mean, 10).timestamp[1] => tenthday
  end
 
  context("upto method accumulates") do
#       @fact upto(cl, sum, 10).values[1]    => roughly(sum(cl.values[1:10]))
#       @fact upto(cl, sum, 10).timestamp[1] => tenthday
  end
end
