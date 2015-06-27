using MarketData

facts("time series methods") do

  context("lag takes previous day and timestamps it to next day") do
      @fact lag(cl).values[1]    => roughly(111.94) 
      @fact lag(cl).timestamp[1] => Date(2000,1,4)
  end

  context("lag accepts kwarg") do
      @fact lag(cl, period=9).timestamp[1] => Date(2000,1,14)
  end

  context("lag operates on 2d arrays") do
      @fact lag(ohlc, period=9).timestamp[1] => Date(2000,1,14)
  end

  context("lag returns 1d from 1d time arrays") do
      @fact ndims(lag(cl).values) => 1
  end

  context("lag returns 2d from 2d time arrays") do
      @fact ndims(lag(ohlc).values) => 2
  end

  context("lead takes next day and timestamps it to current day") do
      @fact lead(cl).values[1]    => roughly(102.5) 
      @fact lead(cl).timestamp[1] => Date(2000,1,3)
  end

  context("lead accepts kwarg") do
      @fact lead(cl, period=9).values[1]    => 100.44 
      @fact lead(cl, period=9).timestamp[1] => Date(2000,1,3)
  end

  context("lead operates on 2d arrays") do
      @fact lead(ohlc, period=9).timestamp[1] => Date(2000,1,3)
  end

  context("lead returns 1d from 1d time arrays") do
      @fact ndims(lead(cl).values) => 1
  end

  context("lead returns 2d from 2d time arrays") do
      @fact ndims(lead(ohlc).values) => 2
  end

  context("correct simple return value") do
      @fact percentchange(cl).values[1] => roughly((102.5-111.94)/111.94)
  end

  context("correct log return value") do
      @fact percentchange(cl, method="log").values[1] => roughly(log(102.5) - log(111.94))
  end

  context("moving supplies correct window length") do
      @fact moving(cl, mean, 10).values[1]    => roughly(sum(cl.values[1:10])/10)
      @fact moving(cl, mean, 10).timestamp[1] => Date(2000,1,14)
  end
 
  context("upto method accumulates") do
      @fact upto(cl, sum).values[10]    => roughly(sum(cl.values[1:10]))
      @fact upto(cl, mean).values[10]   => roughly(sum(cl.values[1:10])/10)
      @fact upto(cl, sum).timestamp[10] => Date(2000,1,14)
  end
end

facts("base element-wise operators on TimeArray values") do

  context("only values on intersecting Dates computed") do
     @fact (cl[1:2] ./ op[2:3]).values[1] => roughly(0.946882) 
     @fact (cl[1:4] .+ op[4:7]).values[1] => roughly(201.12)
     @fact length(cl[1:2] ./ op[2:3])     => 1
     @fact length(cl[1:4] .+ op[4:7])     => 1
  end

  context("correct unary operation on TimeArray values") do
     @fact (+cl).values[1]  => cl.values[1]
     @fact (-cl).values[1]  => -cl.values[1]
     @fact (!(cl .== op)).values[1]  => true
     @fact (+ohlc).values[1,:]  => ohlc.values[1,:]
     @fact (-ohlc).values[1,:]  => -(ohlc.values[1,:])
     @fact (!(ohlc .== ohlc)).values[1,:]  => [false false false false]
  end

  context("correct non-dot operation between TimeArray values and Int/Float64 and viceversa") do
     @fact (cl - 100).values[1] => roughly(11.94)
     @fact (cl + 100).values[1] => roughly(211.94)
     @fact (cl * 100).values[1] => roughly(11194)
     @fact (cl / 100).values[1] => roughly(1.1194)
     @fact (cl % 2).values[1]   =>  cl.values[1] % 2
     @pending (cl ^ 2).values[1]   => roughly(12530.5636)
     @fact (100 - cl).values[1] => roughly(-11.94)
     @fact (100 + cl).values[1] => roughly(211.94)
     @fact (100 * cl).values[1] => roughly(11194)
     @fact_throws (100 / cl).values[1] # related to base not supporting this
     @fact_throws (2 ^ cl).values[1] # base doesn't support this either
     @fact (2 % cl).values[1] => 2 % cl.values[1]
     @fact (ohlc - 100).values[1,:] => ohlc.values[1,:] - 100
     @fact (ohlc + 100).values[1,:] => ohlc.values[1,:] + 100
     @fact (ohlc * 100).values[1,:] => ohlc.values[1,:] * 100
     @fact (ohlc / 100).values[1,:] => ohlc.values[1,:] / 100
     @pending (ohlc ^ 2).values[1,:]   => ohlc.values[1,:] ^ 2
     @fact (ohlc % 2).values[1,:] => ohlc.values[1,:] % 2
     @fact (100 - ohlc).values[1,:] => 100 - ohlc.values[1,:]
     @fact (100 + ohlc).values[1,:] => 100 + ohlc.values[1,:]
     @fact (100 * ohlc).values[1,:] => 100 * ohlc.values[1,:]
     @fact_throws (100 / ohlc).values[1,:] # related to base not supporting this
     @fact_throws (2 ^ ohlc).values[1,:] # base doesn't support this either
     @fact (2 % ohlc).values[1,:] => 2 % ohlc.values[1,:]
  end

  context("correct dot operation between TimeArray values and Int/Float64 and viceversa") do
     @fact (cl .- 100).values[1] => roughly(11.94)
     @fact (cl .+ 100).values[1] => roughly(211.94)
     @fact (cl .* 100).values[1] => roughly(11194)
     @fact (cl ./ 100).values[1] => roughly(1.1194)
     @fact (cl .^ 2).values[1]   => roughly(12530.5636)
     @fact (cl .% 2).values[1]   => cl.values[1] .% 2
     @fact (100 .- cl).values[1] => roughly(-11.94)
     @fact (100 .+ cl).values[1] => roughly(211.94)
     @fact (100 .* cl).values[1] => roughly(11194)
     @fact (100 ./ cl).values[1] => roughly(0.8933357155619082)
     @fact (2 .^ cl).values[1]   => 4980784073277740581384811358191616
     @fact (2 .% cl).values[1]   => 2
     @fact (ohlc .- 100).values[1,:] => ohlc.values[1,:] .- 100
     @fact (ohlc .+ 100).values[1,:] => ohlc.values[1,:] .+ 100
     @fact (ohlc .* 100).values[1,:] => ohlc.values[1,:] .* 100
     @fact (ohlc ./ 100).values[1,:] => ohlc.values[1,:] ./ 100
     @fact (ohlc .^ 2).values[1,:]   => ohlc.values[1,:] .^ 2
     @fact (ohlc .% 2).values[1,:]   => ohlc.values[1,:] .% 2
     @fact (100 .- ohlc).values[1,:] => 100 .- ohlc.values[1,:]
     @fact (100 .+ ohlc).values[1,:] => 100 .+ ohlc.values[1,:]
     @fact (100 .* ohlc).values[1,:] => 100 .* ohlc.values[1,:]
     @fact (100 ./ ohlc).values[1,:] => 100 ./ ohlc.values[1,:]
     @fact (2 .^ ohlc).values[1,:]   => 2 .^ ohlc.values[1,:]
     @fact (2 .% ohlc).values[1,:]   => 2 .% ohlc.values[1,:]
  end

  context("correct alignment and operation between two TimeArrays") do
     @fact (cl .+ op).values[1]      => roughly(216.82)
     @fact (cl .- op).values[1]      => roughly(7.06)
     @fact (cl .* op).values[1]      => roughly(11740.27)
     @fact (cl ./ op).values[1]      => roughly(1.067315)
     @fact (cl .% op).values         => cl.values .% op.values
     @fact (cl .^ op).values         => cl.values .^ op.values
     @fact (ohlc .+ ohlc).values     => ohlc.values .+ ohlc.values
     @fact (ohlc .- ohlc).values     => ohlc.values .- ohlc.values
     @fact (ohlc .* ohlc).values     => ohlc.values .* ohlc.values
     @fact (ohlc ./ ohlc).values     => ohlc.values ./ ohlc.values
     @fact (ohlc .% ohlc).values     => ohlc.values .% ohlc.values
     @fact (ohlc .^ ohlc).values     => ohlc.values .^ ohlc.values
  end

  context("element-wise mathematical operations between 2d time array and 1d time array") do
     @fact (ohlc .+ cl).values => ohlc.values .+ cl.values
     @fact (ohlc .- cl).values => ohlc.values .- cl.values
     @fact (ohlc .* cl).values => ohlc.values .* cl.values
     @fact (ohlc ./ cl).values => ohlc.values ./ cl.values
     @fact (ohlc .% cl).values => ohlc.values .% cl.values
     @fact (ohlc .^ cl).values => ohlc.values .^ cl.values
     @fact (cl .+ ohlc).values => cl.values .+ ohlc.values
     @fact (cl .- ohlc).values => cl.values .- ohlc.values
     @fact (cl .* ohlc).values => cl.values .* ohlc.values
     @fact (cl ./ ohlc).values => cl.values ./ ohlc.values
     @fact (cl .% ohlc).values => cl.values .% ohlc.values
     @fact (cl .^ ohlc).values => cl.values .^ ohlc.values
  end

  context("correct operation between TimeArray values and Int/Float64 (and viceversa) returns bool for comparison") do
     @fact (cl .> 111.94).values[1]  => false
     @fact (cl .< 111.94).values[1]  => false
     @fact (cl .>= 111.94).values[1] => true
     @fact (cl .<= 111.94).values[1] => true
     @fact (cl .== 111.94).values[1] => true
     @fact (111.94 .> cl).values[1]  => false
     @fact (111.94 .< cl).values[1]  => false
     @fact (111.94 .>= cl).values[1] => true
     @fact (111.94 .<= cl).values[1] => true
     @fact (111.94 .== cl).values[1] => true
     @fact (ohlc .> 111.94).values[1,:]  => [false true false false]
     @fact (ohlc .< 111.94).values[1,:]  => [true false true false]
     @fact (ohlc .>= 111.94).values[1,:] => [false true false true]
     @fact (ohlc .<= 111.94).values[1,:] => [true false true true]
     @fact (ohlc .== 111.94).values[1,:] => [false false false true]
     @fact (ohlc .!= 111.94).values[1,:] => [true true true false]
     @fact (111.94 .> ohlc).values[1,:]  => [true false true false]
     @fact (111.94 .< ohlc).values[1,:]  => [false true false false]
     @fact (111.94 .>= ohlc).values[1,:] => [true false true true]
     @fact (111.94 .<= ohlc).values[1,:] => [false true false true]
     @fact (111.94 .== ohlc).values[1,:] => [false false false true]
     @fact (111.94 .!= ohlc).values[1,:] => [true true true false]
  end

  context("correct operation between two TimeArray values returns bool for comparisons") do
     @fact (cl .> op).values[1]  => true
     @fact (cl .< op).values[1]  => false
     @fact (cl .<= op).values[1] => false
     @fact (cl .>= op).values[1] => true
     @fact (cl .== op).values[1] => false
     @fact (cl .!= op).values[1] => true
     @fact (ohlc .> ohlc).values[1,:]  => [false false false false]
     @fact (ohlc .< ohlc).values[1,:]  => [false false false false]
     @fact (ohlc .<= ohlc).values[1,:] => [true true true true]
     @fact (ohlc .>= ohlc).values[1,:] => [true true true true]
     @fact (ohlc .== ohlc).values[1,:] => [true true true true]
     @fact (ohlc .!= ohlc).values[1,:] => [false false false false]
  end

  context("element-wise comparison operations between 2d time array and 1d time array") do
     @fact (ohlc .> cl).values  => ohlc.values .> cl.values
     @fact (ohlc .< cl).values  => ohlc.values .< cl.values
     @fact (ohlc .>= cl).values => ohlc.values .>= cl.values
     @fact (ohlc .<= cl).values => ohlc.values .<= cl.values
     @fact (ohlc .== cl).values => ohlc.values .== cl.values
     @fact (ohlc .!= cl).values => ohlc.values .!= cl.values
     @fact (cl .> ohlc).values  => cl.values .> ohlc.values
     @fact (cl .< ohlc).values  => cl.values .< ohlc.values
     @fact (cl .>= ohlc).values => cl.values .>= ohlc.values
     @fact (cl .<= ohlc).values => cl.values .<= ohlc.values
     @fact (cl .== ohlc).values => cl.values .== ohlc.values
     @fact (cl .!= ohlc).values => cl.values .!= ohlc.values
  end

  context("correct bitwise elementwise operations between bool and TimeArrays' values") do
     @fact ((cl .> 100) & true).values[1] => true
     @fact (false & (cl .> 100)).values[1] => false
     @fact ((cl .> 100) | true).values[1] => true
     @fact (false | (cl .> 100)).values[1] => true
     @fact ((cl .> 100) $ true).values[1] => false
     @fact (false $ (cl .> 100)).values[1] => true
     @fact ((ohlc .> 100) & true).values[4,:] => [true true false false]
     @fact (false & (ohlc .> 100)).values[4,:] => [false false false false]
     @fact ((ohlc .> 100) | true).values[4,:] => [true true true true]
     @fact (false | (ohlc .> 100)).values[4,:] => [true true false false]
     @fact ((ohlc .> 100) $ true).values[4,:] => [false false true true]
     @fact (false $ (ohlc .> 100)).values[4,:] => [true true false false]
  end

  context("correct bitwise elementwise operations between same-dimensioned TimeArrays' boolean values") do
     @fact ((cl .> 100) & (cl .< 120)).values[1] => true
     @fact ((cl .> 100) | (cl .< 120)).values[1] => true
     @fact ((cl .> 100) $ (cl .< 120)).values[1] => false
     @fact ((ohlc .> 100) & (ohlc .< 120)).values[4,:] => [true true false false]
     @fact ((ohlc .> 100) | (ohlc .< 120)).values[4,:] => [true true true true]
     @fact ((ohlc .> 100) $ (ohlc .< 120)).values[4,:] => [false false true true]
  end

end

facts("basecall works with Base methods") do
  
  context("cumsum works") do
    @fact basecall(cl, cumsum).values[2] => cl.values[1] + cl.values[2]
  end
  
  context("log works") do
    @fact basecall(cl, log).values[2] => log(cl.values[2])
  end
end
