using MarketData

facts("collapse operations") do

  context("collapse squishes correctly") do
      @fact collapse(cl, last).values[1]                  => 106.52
      @fact collapse(cl, last).timestamp[1]               => secondday
      @fact collapse(cl, last, period=month).values[1]    => 114.16
      @fact collapse(cl, last, period=month).timestamp[1] => date(1980,1,31)
  end
end

facts("merge works correctly") do
  
  context("returns correct alignment with dates and values") do
    @fact merge(cl,op).values[2,1] => cl.values[2,1]
    @fact merge(cl,op).values[2,2] => op.values[2,1]
  end
  
  context("aligns with disparate sized objects") do
    @fact merge(cl, op[2:5]).values[1,1]  => cl.values[2,1]
    @fact merge(cl, op[2:5]).values[1,2]  => op.values[2,1]
    @fact merge(cl, op[2:5]).timestamp[1] => secondday
    @fact length(merge(cl, op[2:5]))      => 4
  end
end
