using MarketData

facts("type constructors enforce invariants") do

  context("unequal length between values and timestamp fails") do
      @fact_throws TimeArray(cl.timestamp, cl.values[2:end], ["Close"])
  end

  context("unequal length between colnames and array width fails") do
    @fact_throws TimeArray(cl.timestamp, cl.values, ["Close", "Open"])
  end

  context("duplicate timestamp values fails") do
    @fact_throws TimeArray(dupestamp, push!(cl.values, cl.values[1]), ["Close"])
  end

  context("mangled order of timestamp values fails") do
    @fact_throws TimeArray(mangstamp,  push!(cl.values, cl.values[1]), ["Close"])
  end

  context("flipping occurs when needed") do
    @fact TimeArray(flipud(cl.timestamp), flipud(cl.values),  ["Close"]).timestamp[1] => firstday
    @fact TimeArray(flipud(cl.timestamp), flipud(cl.values),  ["Close"]).values[1]    => 105.22
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

  context("getindex on 1d returns 1d object") do
    @fact isa(cl[1], TimeArray{Float64,1})   => true
    @fact isa(cl[1:2], TimeArray{Float64,1}) => true
  end
end
