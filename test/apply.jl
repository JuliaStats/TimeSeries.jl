using MarketData

facts("time series methods") do

    context("lag takes previous day and timestamps it to next day") do
        @fact lag(cl).values[1]    --> roughly(111.94, atol=.01)
        @fact lag(cl).timestamp[1] --> Date(2000,1,4)
    end

    context("lag accepts kwarg") do
        @fact lag(cl, period=9).timestamp[1] --> Date(2000,1,14)
    end

    context("lag operates on 2d arrays") do
        @fact lag(ohlc, period=9).timestamp[1] --> Date(2000,1,14)
    end

    context("lag returns 1d from 1d time arrays") do
        @fact ndims(lag(cl).values) --> 1
    end

    context("lag returns 2d from 2d time arrays") do
        @fact ndims(lag(ohlc).values) --> 2
    end

    context("lead takes next day and timestamps it to current day") do
        @fact lead(cl).values[1]    --> roughly(102.5, atol=.1)
        @fact lead(cl).timestamp[1] --> Date(2000,1,3)
    end

    context("lead accepts kwarg") do
        @fact lead(cl, period=9).values[1]    --> 100.44
        @fact lead(cl, period=9).timestamp[1] --> Date(2000,1,3)
    end

    context("lead operates on 2d arrays") do
        @fact lead(ohlc, period=9).timestamp[1] --> Date(2000,1,3)
    end

    context("lead returns 1d from 1d time arrays") do
        @fact ndims(lead(cl).values) --> 1
    end

    context("lead returns 2d from 2d time arrays") do
        @fact ndims(lead(ohlc).values) --> 2
    end

    context("correct simple return value") do
        @fact percentchange(cl).values[1] --> roughly((102.5-111.94)/111.94, atol=.01)
    end

    context("correct log return value") do
        @fact percentchange(cl, method="log").values[1] --> roughly(log(102.5) - log(111.94), atol=.01)
    end

    context("moving supplies correct window length") do
        @fact moving(cl, mean, 10).values[1]    --> roughly(sum(cl.values[1:10])/10, atol=.01)
        @fact moving(cl, mean, 10).timestamp[1] --> Date(2000,1,14)
    end

    context("upto method accumulates") do
        @fact upto(cl, sum).values[10]    --> roughly(sum(cl.values[1:10]), atol=.01)
        @fact upto(cl, mean).values[10]   --> roughly(sum(cl.values[1:10])/10, atol=.01)
        @fact upto(cl, sum).timestamp[10] --> Date(2000,1,14)
    end
end

facts("base element-wise operators on TimeArray values") do

    context("only values on intersecting Dates computed") do
        @fact (cl[1:2] ./ op[2:3]).values[1] --> roughly(0.94688222)
        @fact (cl[1:4] .+ op[4:7]).values[1] --> roughly(201.12, atol=.01)
        @fact length(cl[1:2] ./ op[2:3])     --> 1
        @fact length(cl[1:4] .+ op[4:7])     --> 1
    end

    context("correct unary operation on TimeArray values") do
        @fact (+cl).values[1]  --> cl.values[1]
        @fact (-cl).values[1]  --> -cl.values[1]
        @fact (!(cl .== op)).values[1]  --> true
        @fact (+ohlc).values[1,:]  --> ohlc.values[1,:]
        @fact (-ohlc).values[1,:]  --> -(ohlc.values[1,:])
        @fact (!(ohlc .== ohlc)).values[1,1]  --> false
    end

    context("correct dot operation between TimeArray values and Int/Float and viceversa") do
        @fact (cl .- 100).values[1] --> roughly(11.94, atol=.01)
        @fact (cl .+ 100).values[1] --> roughly(211.94, atol=.01)
        @fact (cl .* 100).values[1] --> roughly(11194, atol=1)
        @fact (cl ./ 100).values[1] --> roughly(1.1194, atol=.0001)
        @fact (cl .^ 2).values[1]   --> roughly(12530.5636, atol=.0001)
        @fact (cl .% 2).values[1]   --> cl.values[1] % 2
        @fact (100 .- cl).values[1] --> roughly(-11.94, atol=.01)
        @fact (100 .+ cl).values[1] --> roughly(211.94, atol=.01)
        @fact (100 .* cl).values[1] --> roughly(11194, atol=.01)
        @fact (100 ./ cl).values[1] --> roughly(0.8933357155619082)
        @fact (2 .^ cl).values[1]   --> 4980784073277740581384811358191616
        @fact (2 .% cl).values[1]   --> 2
        @fact (ohlc .- 100).values[1,:] --> ohlc.values[1,:] .- 100
        @fact (ohlc .+ 100).values[1,:] --> ohlc.values[1,:] .+ 100
        @fact (ohlc .* 100).values[1,:] --> ohlc.values[1,:] .* 100
        @fact (ohlc ./ 100).values[1,:] --> ohlc.values[1,:] ./ 100
        @fact (ohlc .^ 2).values[1,:]   --> ohlc.values[1,:] .^ 2
        @fact (ohlc .% 2).values[1,:]   --> ohlc.values[1,:] .% 2
        @fact (100 .- ohlc).values[1,:] --> 100 .- ohlc.values[1,:]
        @fact (100 .+ ohlc).values[1,:] --> 100 .+ ohlc.values[1,:]
        @fact (100 .* ohlc).values[1,:] --> 100 .* ohlc.values[1,:]
        @fact (100 ./ ohlc).values[1,:] --> 100 ./ ohlc.values[1,:]
        @fact (2 .^ ohlc).values[1,:]   --> 2 .^ ohlc.values[1,:]
        @fact (2 .% ohlc).values[1,:]   --> 2 .% ohlc.values[1,:]
    end

    context("correct non-dot operation between TimeArray values and Int/Float and viceversa") do
        @fact (cl - 100).values[1] --> roughly(11.94, atol=0.1)
        @fact (cl + 100).values[1] --> roughly(211.94, atol=0.1)
        @fact (cl * 100).values[1] --> roughly(11194, atol=0.1)
        @fact (cl / 100).values[1] --> roughly(1.1194, atol=0.001)
        @fact (cl % 2).values[1]   -->  cl.values[1] % 2
        # not supported by Base - reserved for square matrix multiplication
        @fact_throws (cl ^ 2).values[1]
        @fact (100 - cl).values[1] --> roughly(-11.94, atol=0.1)
        @fact (100 + cl).values[1] --> roughly(211.94, atol=0.1)
        @fact (100 * cl).values[1] --> roughly(11194, atol=0.1)
        # not supported by Base - confusion with matrix inverse
        @fact_throws (100 / cl).values
        # not supported by Base
        @fact_throws (2 ^ cl).values
        @fact (2 % cl).values[1] --> 2 % cl.values[1]
        @fact (ohlc - 100).values[1,:] --> ohlc.values[1,:] - 100
        @fact (ohlc + 100).values[1,:] --> ohlc.values[1,:] + 100
        @fact (ohlc * 100).values[1,:] --> ohlc.values[1,:] * 100
        @fact (ohlc / 100).values[1,:] --> ohlc.values[1,:] / 100
        # not supported by Base - reserved for square matrix multiplication
        @fact_throws (ohlc ^ 2).values[1,:]
        @fact (ohlc % 2).values[1,:] --> ohlc.values[1,:] % 2
        @fact (100 - ohlc).values[1,:] --> 100 - ohlc.values[1,:]
        @fact (100 + ohlc).values[1,:] --> 100 + ohlc.values[1,:]
        @fact (100 * ohlc).values[1,:] --> 100 * ohlc.values[1,:]
        # not supported by Base - confusion with matrix inverse
        @fact_throws (100 / ohlc).values[1,:]
        # not supported by Base
        @fact_throws (2 ^ ohlc).values[1,:]
        @fact (2 % ohlc).values[1,:] --> 2 % ohlc.values[1,:]
    end

    context("correct mathematical operations between two same-column-count TimeArrays") do
        @fact (cl .+ op).values[1]      --> roughly(216.82, atol=.01)
        @fact (cl .- op).values[1]      --> roughly(7.06, atol=.01)
        @fact (cl .* op).values[1]      --> roughly(11740.2672, atol=0.0001)
        @fact (cl ./ op).values[1]      --> roughly(1.067315, atol=0.001)
        @fact (cl .% op).values         --> cl.values .% op.values
        @fact (cl .^ op).values         --> cl.values .^ op.values
        @fact (ohlc .+ ohlc).values     --> ohlc.values .+ ohlc.values
        @fact (ohlc .- ohlc).values     --> ohlc.values .- ohlc.values
        @fact (ohlc .* ohlc).values     --> ohlc.values .* ohlc.values
        @fact (ohlc ./ ohlc).values     --> ohlc.values ./ ohlc.values
        @fact (ohlc .% ohlc).values     --> ohlc.values .% ohlc.values
        @fact (ohlc .^ ohlc).values     --> ohlc.values .^ ohlc.values
    end

    context("correct broadcasted mathematical operations between different-column-count TimeArrays") do
        @fact (ohlc .+ cl).values --> ohlc.values .+ cl.values
        @fact (ohlc .- cl).values --> ohlc.values .- cl.values
        @fact (ohlc .* cl).values --> ohlc.values .* cl.values
        @fact (ohlc ./ cl).values --> ohlc.values ./ cl.values
        @fact (ohlc .% cl).values --> ohlc.values .% cl.values
        @fact (ohlc .^ cl).values --> ohlc.values .^ cl.values
        @fact (cl .+ ohlc).values --> cl.values .+ ohlc.values
        @fact (cl .- ohlc).values --> cl.values .- ohlc.values
        @fact (cl .* ohlc).values --> cl.values .* ohlc.values
        @fact (cl ./ ohlc).values --> cl.values ./ ohlc.values
        @fact (cl .% ohlc).values --> cl.values .% ohlc.values
        @fact (cl .^ ohlc).values --> cl.values .^ ohlc.values
        @fact_throws (ohlc["Open", "Close"] .+ ohlc) # One array must have a single column
    end

    context("correct comparison operations between TimeArray values and Int/Float (and viceversa)") do
        @fact (cl .> 111.94).values[1]  --> false
        @fact (cl .< 111.94).values[1]  --> false
        @fact (cl .>= 111.94).values[1] --> true
        @fact (cl .<= 111.94).values[1] --> true
        @fact (cl .== 111.94).values[1] --> true
        @fact (cl .!= 111.94).values[1] --> false
        @fact (111.94 .> cl).values[1]  --> false
        @fact (111.94 .< cl).values[1]  --> false
        @fact (111.94 .>= cl).values[1] --> true
        @fact (111.94 .<= cl).values[1] --> true
        @fact (111.94 .== cl).values[1] --> true
        @fact (111.94 .!= cl).values[1] --> false
        @fact (ohlc .> 111.94).values[1,:]  --> [false true false false]
        @fact (ohlc .< 111.94).values[1,:]  --> [true false true false]
        @fact (ohlc .>= 111.94).values[1,:] --> [false true false true]
        @fact (ohlc .<= 111.94).values[1,:] --> [true false true true]
        @fact (ohlc .== 111.94).values[1,:] --> [false false false true]
        @fact (ohlc .!= 111.94).values[1,:] --> [true true true false]
        @fact (111.94 .> ohlc).values[1,:]  --> [true false true false]
        @fact (111.94 .< ohlc).values[1,:]  --> [false true false false]
        @fact (111.94 .>= ohlc).values[1,:] --> [true false true true]
        @fact (111.94 .<= ohlc).values[1,:] --> [false true false true]
        @fact (111.94 .== ohlc).values[1,:] --> [false false false true]
        @fact (111.94 .!= ohlc).values[1,:] --> [true true true false]
    end

    context("correct comparison operations between TimeArray values and Bool (and viceversa)") do
        @fact ((cl .> 111.94) .== true).values[1] --> false
        @fact ((cl .> 111.94) .!= true).values[1] --> true
        @fact (true .== (cl .> 111.94)).values[1] --> false
        @fact (true .!= (cl .> 111.94)).values[1] --> true
        @fact ((ohlc .> 111.94).== true).values[1,:] --> [false true false false]
        @fact ((ohlc .> 111.94).!= true).values[1,:] --> [true false true true]
        @fact (true .== (ohlc .> 111.94)).values[1,:] --> [false true false false]
        @fact (true .!= (ohlc .> 111.94)).values[1,:] --> [true false true true]
    end

    context("correct comparison operations between same-column-count TimeArrays") do
        @fact (cl .> op).values[1]  --> true
        @fact (cl .< op).values[1]  --> false
        @fact (cl .<= op).values[1] --> false
        @fact (cl .>= op).values[1] --> true
        @fact (cl .== op).values[1] --> false
        @fact (cl .!= op).values[1] --> true
        @fact (ohlc .> ohlc).values[1,:]  --> [false false false false]
        @fact (ohlc .< ohlc).values[1,:]  --> [false false false false]
        @fact (ohlc .<= ohlc).values[1,:] --> [true true true true]
        @fact (ohlc .>= ohlc).values[1,:] --> [true true true true]
        @fact (ohlc .== ohlc).values[1,:] --> [true true true true]
        @fact (ohlc .!= ohlc).values[1,:] --> [false false false false]
    end

    context("correct comparison operations between different-column-count TimeArrays") do
        @fact (ohlc .> cl).values  --> ohlc.values .> cl.values
        @fact (ohlc .< cl).values  --> ohlc.values .< cl.values
        @fact (ohlc .>= cl).values --> ohlc.values .>= cl.values
        @fact (ohlc .<= cl).values --> ohlc.values .<= cl.values
        @fact (ohlc .== cl).values --> ohlc.values .== cl.values
        @fact (ohlc .!= cl).values --> ohlc.values .!= cl.values
        @fact (cl .> ohlc).values  --> cl.values .> ohlc.values
        @fact (cl .< ohlc).values  --> cl.values .< ohlc.values
        @fact (cl .>= ohlc).values --> cl.values .>= ohlc.values
        @fact (cl .<= ohlc).values --> cl.values .<= ohlc.values
        @fact (cl .== ohlc).values --> cl.values .== ohlc.values
        @fact (cl .!= ohlc).values --> cl.values .!= ohlc.values
        @fact_throws (ohlc["Open", "Close"] .== ohlc) # One array must have a single column
    end

    context("correct bitwise elementwise operations between bool and TimeArrays' values") do
        @fact ((cl .> 100) & true).values[1] --> true
        @fact ((cl .> 100) | true).values[1] --> true
        @fact ((cl .> 100) $ true).values[1] --> false
        @fact (false & (cl .> 100)).values[1] --> false
        @fact (false | (cl .> 100)).values[1] --> true
        @fact (false $ (cl .> 100)).values[1] --> true
        @fact ((ohlc .> 100) & true).values[4,:] --> [true true false false]
        @fact ((ohlc .> 100) | true).values[4,:] --> [true true true true]
        @fact ((ohlc .> 100) $ true).values[4,:] --> [false false true true]
        @fact (false & (ohlc .> 100)).values[4,:] --> [false false false false]
        @fact (false | (ohlc .> 100)).values[4,:] --> [true true false false]
        @fact (false $ (ohlc .> 100)).values[4,:] --> [true true false false]
      end

    context("correct bitwise elementwise operations between same-column-count TimeArrays' boolean values") do
        @fact ((cl .> 100) & (cl .< 120)).values[1] --> true
        @fact ((cl .> 100) | (cl .< 120)).values[1] --> true
        @fact ((cl .> 100) $ (cl .< 120)).values[1] --> false
        @fact ((ohlc .> 100) & (ohlc .< 120)).values[4,:] --> [true true false false]
        @fact ((ohlc .> 100) | (ohlc .< 120)).values[4,:] --> [true true true true]
        @fact ((ohlc .> 100) $ (ohlc .< 120)).values[4,:] --> [false false true true]
        @fact_throws ((ohlc .> 100) $ (cl.< 120)) # Bitwise broadcasting not supported by Base
    end

end

facts("basecall works with Base methods") do

    context("cumsum works") do
        @fact basecall(cl, cumsum).values[2] --> cl.values[1] + cl.values[2]
    end

    context("log works") do
        @fact basecall(cl, log).values[2] --> log(cl.values[2])
    end
end
