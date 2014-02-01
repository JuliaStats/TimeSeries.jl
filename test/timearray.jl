using MarketData

ohlc = TimeArray(op, hi, lo, cl)

facts("Base methods") do
  
  context("getindex on single Int and DateTime") do
    @fact ohlc[1].timestamp        => [firstday]
    @fact ohlc[firstday].timestamp => [firstday]
  end
  
  context("getindex on array of Int and DateTime") do
    @fact ohlc[[1,10]].timestamp              => [firstday, tenthday]
    @fact ohlc[[firstday,tenthday]].timestamp => [firstday, tenthday]
  end

  context("getindex on range of Int and DateTime") do
    @fact ohlc[1:2].timestamp                        => [firstday, secondday]
    @fact ohlc[firstday:days(1):secondday].timestamp => [firstday, secondday]
  end
end
