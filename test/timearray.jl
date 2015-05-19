using MarketData

facts("field extraction methods work") do
    @fact typeof(timestamp(cl)) => Array{Date,1}
    @fact typeof(values(cl))    => Array{Float64,1}
    @fact typeof(colnames(cl))  => Array{UTF8String,1}
    @pending meta(mdata)        => "Apple" 
end

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
    @fact TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).timestamp[1] => Date(2000,1,3)
    @fact TimeArray(flipdim(cl.timestamp, 1), flipdim(cl.values, 1),  ["Close"]).values[1]    => 111.94
  end
end
  
facts("conversion methods") do
    @fact isa(convert(TimeArray{Float64,1}, (cl.>op)), TimeArray{Float64,1})                => true
    @fact isa(convert(TimeArray{Float64,2}, (merge(cl.<op, cl.>op))), TimeArray{Float64,2}) => true
    @fact isa(convert(cl.>op), TimeArray{Float64,1})                                        => true
    @fact isa(convert(merge(cl.<op, cl.>op)), TimeArray{Float64,2})                         => true
end

facts("getindex methods") do
  
  context("getindex on single Int and Date") do
    @fact ohlc[1].timestamp              => [Date(2000,1,3)]
    @fact ohlc[Date(2000,1,3)].timestamp => [Date(2000,1,3)]
  end
  
  context("getindex on array of Int and Date") do
    @fact ohlc[[1,10]].timestamp                           => [Date(2000,1,3), Date(2000,1,14)]
    @fact ohlc[[Date(2000,1,3),Date(2000,1,14)]].timestamp => [Date(2000,1,3), Date(2000,1,14)]
  end

  context("getindex on range of Int and Date") do
    @fact ohlc[1:2].timestamp                                  => [Date(2000,1,3), Date(2000,1,4)]
    @fact ohlc[Date(2000,1,3):Day(1):Date(2000,1,4)].timestamp => [Date(2000,1,3), Date(2000,1,4)]
  end

  # TODO get meaningful tests
  context("getindex on range of DateTime when only Date is in timestamp") do
    @fact ohlc[DateTime(2000,1,3,0,0,0)].timestamp                                 => [DateTime(2000,1,3,0,0,0)]
    @fact ohlc[[DateTime(2000,1,3,0,0,0),DateTime(2000,1,14,0,0,0)]].timestamp     => [DateTime(2000,1,3,0,0,0), DateTime(2000,1,14,0,0,0)]
    @fact ohlc[DateTime(2000,1,3,0,0,0):Day(1):DateTime(2000,1,4,0,0,0)].timestamp => [DateTime(2000,1,3,0,0,0), DateTime(2000,1,4,0,0,0)]
  end

  context("getindex on range of Date") do
    @fact length(cl[Date(2000,1,1):Date(2001,12,31)]) => 500
  end

  context("getindex on single column name") do
    @fact size(ohlc["Open"].values, 2)                                        => 1
    @fact size(ohlc["Open"][Date(2000,1,3):Day(1):Date(2000,1,14)].values, 1) => 10
  end

  context("getindex on multiple column name") do
    @fact ohlc["Open", "Close"].values[1]   => 104.88
    @fact ohlc["Open", "Close"].values[2]   => 108.25
    @fact ohlc["Open", "Close"].values[501] => 111.94
  end

  context("getindex on 1d returns 1d object") do
    @fact isa(cl[1], TimeArray{Float64,1})   => true
    @fact isa(cl[1:2], TimeArray{Float64,1}) => true
  end
end
