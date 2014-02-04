using MarketData

ohlc             = TimeArray(op, hi, lo, cl)
ohlc.colnames[1] = "Open"
ohlc.colnames[2] = "High"
ohlc.colnames[3] = "Low"
ohlc.colnames[4] = "Close"

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

  context("getindex on single column name") do
    @fact size(ohlc["Open"].values, 2)                            => 1
    @fact size(ohlc["Open"][firstday:days(1):tenthday].values, 1) => 10
  end

  context("getindex on multiple column name") do
    @fact ohlc["Open", "Close"].values[1] => 105.76
    @fact ohlc["Open", "Close"].values[2] => 105.22
  end
end
