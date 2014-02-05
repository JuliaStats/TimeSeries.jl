using MarketData

ohlc             = TimeArray(op, hi, lo, cl)
ohlc.colnames[1] = "Open"
ohlc.colnames[2] = "High"
ohlc.colnames[3] = "Low"
ohlc.colnames[4] = "Close"

facts("type constructors enforce invariants") do

  context("unequal length between values and timestamp fails") do
      @fact_throws TimeArray(index(cl), value(cl)[2:end], ["Close"])
  end

  context("unequal length between colnames and array width fails") do
    @fact_throws TimeArray(index(cl), value(cl), ["Close", "Open"])
  end

  context("duplicate timestamp values fails") do
    @fact_throws TimeArray(push!(index(cl), index(cl)[505]), push!(value(cl), value(cl)[1]), ["Close"])
  end

  context("mangled order of timestamp values fails") do
    @fact_throws TimeArray(push!(index(cl), date(1981,12,25)), push!(value(cl), value(cl)[1]), ["Close"])
  end

  context("flipping occurs when needed") do
    @fact TimeArray(flipud(index(cl)), flipud(value(cl)),  ["Close"]).timestamp[1] => firstday
    @fact TimeArray(flipud(index(cl)), flipud(value(cl)),  ["Close"]).values[1]    => 105.22
  end
end
  
facts("getindex methods") do
  
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
