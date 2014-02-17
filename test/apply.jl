using MarketData

facts("time series methods") do

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
      @fact moving(cl, mean, 10).values[1]    => roughly(sum(cl.values[1:10])/10)
      @fact moving(cl, mean, 10).timestamp[1] => tenthday
  end
 
  context("upto method accumulates") do
      @fact upto(cl, sum).values[10]    => roughly(sum(cl.values[1:10]))
      @fact upto(cl, mean).values[10]   => roughly(sum(cl.values[1:10])/10)
      @fact upto(cl, sum).timestamp[10] => tenthday
  end
end

facts("base element-wise operators on TimeArray values") do

  context("correct alignment and operation between two TimeVectors") do
    @fact (cl .+ op).values[1]           => roughly(210.98)
    @fact (cl .- op).values[1]           => roughly(-0.54)
    @fact (cl .* op).values[1]           => roughly(11128.07)
    @fact (cl ./ op).values[1]           => roughly(0.99489)
  end

  context("only values on intersecting dates computed") do
    @fact (cl[1:2] ./ op[2:3]).values[1] => roughly(1.012355) 
    @fact (cl[1:4] .+ op[4:7]).values[1] => roughly(215.76)
    @fact length(cl[1:2] ./ op[2:3])     => 1
    @fact length(cl[1:4] .+ op[4:7])     => 1
  end

  context("correct dot operation between TimeVectors values and Int/Float64 and viceversa") do
    @fact (cl .- 100).values[1] => roughly(5.22)
    @fact (cl .+ 100).values[1] => roughly(205.22)
    @fact (cl .* 100).values[1] => roughly(10522)
    @fact (cl ./ 100).values[1] => roughly(1.0522)
    @fact (cl .^ 2).values[1]   => roughly(11071.2)
    @fact (100 .- cl).values[1] => roughly(-5.22)
    @fact (100 .+ cl).values[1] => roughly(205.22)
    @fact (100 .* cl).values[1] => roughly(10522)
    @fact (100 ./ cl).values[1] => roughly(0.95038965976)
    @fact (2 .^ cl).values[1]   => 47247207359766887073934601093120
  end

  context("correct non-dot operation between TimeVectors values and Int/Float64 and viceversa") do
    @fact (cl - 100).values[1] => roughly(5.22)
    @fact (cl + 100).values[1] => roughly(205.22)
    @fact (cl * 100).values[1] => roughly(10522)
    @fact (cl / 100).values[1] => roughly(1.0522)
    # @fact_throws (cl ^ 2).values[1]   # not supported in Base butnot erroring out ~ strange
    @fact (100 - cl).values[1] => roughly(-5.22)
    @fact (100 + cl).values[1] => roughly(205.22)
    @fact (100 * cl).values[1] => roughly(10522)
    @fact (100 / cl).values[1] => roughly(0.95038965976)
    @fact_throws (2 ^ cl).values[1]  # not written
  end

  context("correct operation between two TimeVectors values returns bool for comparisons") do
    @fact (cl .> op).values[1]  => false
    @fact (cl .< op).values[1]  => true
    @fact (cl .<= op).values[1] => true
    @fact (cl .>= op).values[1] => false
    @fact (cl .== op).values[1] => false
  end

  context("correct operation between TimeVectors values and Int/Float64 (and viceversa) returns bool for comparison") do
    @fact (cl .> 105.22).values[1]  => false
    @fact (cl .< 105.22).values[1]  => false
    @fact (cl .>= 105.22).values[1] => true
    @fact (cl .<= 105.22).values[1] => true
    @fact (cl .== 105.22).values[1] => true
    @fact (105.22 .> cl).values[1]  => false
    @fact (105.22 .< cl).values[1]  => false
    @fact (105.22 .>= cl).values[1] => true
    @fact (105.22 .<= cl).values[1] => true
    @fact (105.22 .== cl).values[1] => true
  end
end
