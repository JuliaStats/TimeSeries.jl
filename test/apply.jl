using TimeSeries, MarketData
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("time series methods") do

    context("lag takes previous day and timestamps it to next day") do
        @fact lag(cl).values[1]    --> roughly(111.94, atol=.01)
        @fact lag(cl).timestamp[1] --> Date(2000,1,4)
    end

    context("lag accepts other offset values") do
        @fact lag(cl, 9).timestamp[1] --> Date(2000,1,14)
    end

    context("lag operates on 2d arrays") do
        @fact lag(ohlc, 9).timestamp[1] --> Date(2000,1,14)
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

    context("lead accepts other offset values") do
        @fact lead(cl, 9).values[1]    --> 100.44
        @fact lead(cl, 9).timestamp[1] --> Date(2000,1,3)
    end

    context("lead operates on 2d arrays") do
        @fact lead(ohlc, 9).timestamp[1] --> Date(2000,1,3)
    end

    context("lead returns 1d from 1d time arrays") do
        @fact ndims(lead(cl).values) --> 1
    end

    context("lead returns 2d from 2d time arrays") do
        @fact ndims(lead(ohlc).values) --> 2
    end

    context("diff calculates 1st-order differences") do
        @fact diff(op).timestamp                              --> diff(op, padding=false).timestamp
        @fact diff(op).values                                 --> diff(op, padding=false).values
        @fact diff(op, padding=false).values[1]               --> op[2].values[1] .- op[1].values[1]
        @fact isequal(diff(op, padding=true).values[1], NaN)  --> true
        @fact diff(op, padding=true).values[2]                --> diff(op).values[1]
        @fact diff(op, padding=true).values[2]                --> op[2].values[1] .- op[1].values[1]
    end

    context("correct simple return value") do
        @fact percentchange(cl, :simple).values              --> percentchange(cl).values
        @fact percentchange(cl).values                       --> percentchange(cl, padding=false).values
        @fact percentchange(cl).values[1]                    --> roughly((102.5-111.94)/111.94, atol=.01)
        @fact percentchange(ohlc).values[1, :]               --> roughly((ohlc.values[2,:] - ohlc.values[1,:]) ./ ohlc.values[1,:])
        @fact percentchange(cl, padding=true).values[1]      --> isnan
        @fact percentchange(cl, padding=true).values[2]      --> roughly((102.5-111.94)/111.94, atol=.01)
        @fact percentchange(ohlc, padding=true).values[2, :] --> roughly((ohlc.values[2,:] - ohlc.values[1,:]) ./ ohlc.values[1,:])
    end

    context("correct log return value") do
        @fact percentchange(cl, :log).values                       --> percentchange(cl, :log, padding=false).values
        @fact percentchange(cl, :log).values[1]                    --> roughly(log(102.5) - log(111.94), atol=.01)
        @fact percentchange(ohlc, :log).values[1, :]               --> roughly(log(ohlc.values[2,:]) - log(ohlc.values[1,:]), atol=.01)
        @fact percentchange(cl, :log, padding=true).values[1]      --> isnan
        @fact percentchange(cl, :log, padding=true).values[2]      --> roughly(log(102.5) - log(111.94))
        @fact percentchange(ohlc, :log, padding=true).values[2, :] --> roughly(log(ohlc.values[2,:]) - log(ohlc.values[1,:]))
    end

    context("moving supplies correct window length") do
        @fact moving(cl, mean, 10).values                                                      --> moving(cl, mean, 10, padding=false).values
        @fact moving(cl, mean, 10).timestamp[1]                                                --> Date(2000,1,14)
        @fact moving(cl, mean, 10).values[1]                                                   --> roughly(mean(cl.values[1:10]))
        @fact moving(cl, mean, 10, padding=true).timestamp[1]                                  --> Date(2000,1, 3)
        @fact moving(cl, mean, 10, padding=true).timestamp[10]                                 --> Date(2000,1,14)
        @fact isequal(moving(cl, mean, 10, padding=true).values[1], NaN)                       --> true
        @fact moving(cl, mean, 10, padding=true).values[10]                                    --> moving(cl, mean, 10).values[1]
        @fact moving(ohlc, mean, 10).values                                                    --> moving(ohlc, mean, 10, padding=false).values
        @fact moving(ohlc, mean, 10).values[1, :]'                                             --> roughly(mean(ohlc.values[1:10, :], 1))
        @fact isequal(moving(ohlc, mean, 10, padding=true).values[1, :], [NaN, NaN, NaN, NaN]) --> true
        @fact moving(ohlc, mean, 10, padding=true).values[10, :]                               --> moving(ohlc, mean, 10).values[1, :]
    end

    context("upto method accumulates") do
        @fact upto(cl, sum).values[10]        --> roughly(sum(cl.values[1:10]))
        @fact upto(cl, mean).values[10]       --> roughly(mean(cl.values[1:10]))
        @fact upto(cl, sum).timestamp[10]     --> Date(2000,1,14)
        # transpose the upto value output from column to row vector but values are identical
        @fact upto(ohlc, sum).values[10, :]'  --> roughly(sum(ohlc.values[1:10, :], 1))
        @fact upto(ohlc, mean).values[10, :]' --> roughly(mean(ohlc.values[1:10, :], 1))
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
        @fact (+cl).values[1]                --> cl.values[1]
        @fact (-cl).values[1]                --> -cl.values[1]
        @fact (!(cl .== op)).values[1]       --> true
        @fact log(cl).values[1]              --> log(cl.values[1])
        @fact sqrt(cl).values[1]             --> sqrt(cl.values[1])
        @fact (+ohlc).values[1,:]            --> ohlc.values[1,:]
        @fact (-ohlc).values[1,:]            --> -(ohlc.values[1,:])
        @fact (!(ohlc .== ohlc)).values[1,1] --> false
        @fact log(ohlc).values[1, :]         --> log(ohlc.values[1, :])
        @fact sqrt(ohlc).values[1, :]        --> sqrt(ohlc.values[1, :])
        @fact_throws sqrt(-ohlc)
    end

    context("correct dot operation between TimeArray values and Int/Float and viceversa") do
        @fact (cl .- 100).values[1]     --> roughly(11.94, atol=.01)
        @fact (cl .+ 100).values[1]     --> roughly(211.94, atol=.01)
        @fact (cl .* 100).values[1]     --> roughly(11194, atol=1)
        @fact (cl ./ 100).values[1]     --> roughly(1.1194, atol=.0001)
        @fact (cl .^ 2).values[1]       --> roughly(12530.5636, atol=.0001)
        @fact (cl .% 2).values[1]       --> cl.values[1] % 2
        @fact (100 .- cl).values[1]     --> roughly(-11.94, atol=.01)
        @fact (100 .+ cl).values[1]     --> roughly(211.94, atol=.01)
        @fact (100 .* cl).values[1]     --> roughly(11194, atol=.01)
        @fact (100 ./ cl).values[1]     --> roughly(0.8933357155619082)
        @fact (2 .^ cl).values[1]       --> 4980784073277740581384811358191616
        @fact (2 .% cl).values[1]       --> 2
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
        @fact (2 % cl).values[1]       --> 2 % cl.values[1]
        @fact (ohlc - 100).values[1,:] --> ohlc.values[1,:] - 100
        @fact (ohlc + 100).values[1,:] --> ohlc.values[1,:] + 100
        @fact (ohlc * 100).values[1,:] --> ohlc.values[1,:] * 100
        @fact (ohlc / 100).values[1,:] --> ohlc.values[1,:] / 100
        # not supported by Base - reserved for square matrix multiplication
        @fact_throws (ohlc ^ 2).values[1,:]
        @fact (ohlc % 2).values[1,:]   --> ohlc.values[1,:] % 2
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
        @fact (cl .+ op).values[1]                              --> roughly(216.82, atol=.01)
        @fact (cl .- op).values[1]                              --> roughly(7.06, atol=.01)
        @fact (cl .* op).values[1]                              --> roughly(11740.2672, atol=0.0001)
        @fact (cl ./ op).values[1]                              --> roughly(1.067315, atol=0.001)
        @fact (cl .% op).values                                 --> cl.values .% op.values
        @fact (cl .^ op).values                                 --> cl.values .^ op.values
        @fact (cl .* (cl.> 200)).values                         --> cl.values .* (cl.values .> 200)
        @fact (basecall(cl, x->round(Int, x)) .* cl).values     --> round(Int, cl.values) .* cl.values
        @fact (ohlc .+ ohlc).values                             --> ohlc.values .+ ohlc.values
        @fact (ohlc .- ohlc).values                             --> ohlc.values .- ohlc.values
        @fact (ohlc .* ohlc).values                             --> ohlc.values .* ohlc.values
        @fact (ohlc ./ ohlc).values                             --> ohlc.values ./ ohlc.values
        @fact (ohlc .% ohlc).values                             --> ohlc.values .% ohlc.values
        @fact (ohlc .^ ohlc).values                             --> ohlc.values .^ ohlc.values
        @fact (ohlc .* (ohlc .> 200)).values                    --> ohlc.values .* (ohlc.values .> 200)
        @fact (basecall(ohlc, x->round(Int, x)) .* ohlc).values --> round(Int, ohlc.values) .* ohlc.values
    end

    context("correct broadcasted mathematical operations between different-column-count TimeArrays") do
        @fact (ohlc .+ cl).values                             --> ohlc.values .+ cl.values
        @fact (ohlc .- cl).values                             --> ohlc.values .- cl.values
        @fact (ohlc .* cl).values                             --> ohlc.values .* cl.values
        @fact (ohlc ./ cl).values                             --> ohlc.values ./ cl.values
        @fact (ohlc .% cl).values                             --> ohlc.values .% cl.values
        @fact (ohlc .^ cl).values                             --> ohlc.values .^ cl.values
        @fact (ohlc .* (cl.> 200)).values                     --> ohlc.values .* (cl.values .> 200)
        @fact (basecall(ohlc, x->round(Int, x)) .* cl).values --> round(Int, ohlc.values) .* cl.values
        @fact (cl .+ ohlc).values                             --> cl.values .+ ohlc.values
        @fact (cl .- ohlc).values                             --> cl.values .- ohlc.values
        @fact (cl .* ohlc).values                             --> cl.values .* ohlc.values
        @fact (cl ./ ohlc).values                             --> cl.values ./ ohlc.values
        @fact (cl .% ohlc).values                             --> cl.values .% ohlc.values
        @fact (cl .^ ohlc).values                             --> cl.values .^ ohlc.values
        @fact (cl .* (ohlc .> 200)).values                    --> cl.values .* (ohlc.values .> 200)
        @fact (basecall(cl, x->round(Int, x)) .* ohlc).values --> round(Int, cl.values) .* ohlc.values
        @fact_throws (ohlc["Open", "Close"] .+ ohlc) # One array must have a single column
    end

    context("correct comparison operations between TimeArray values and Int/Float (and viceversa)") do
        @fact (cl .> 111.94).values[1]      --> false
        @fact (cl .< 111.94).values[1]      --> false
        @fact (cl .>= 111.94).values[1]     --> true
        @fact (cl .<= 111.94).values[1]     --> true
        @fact (cl .== 111.94).values[1]     --> true
        @fact (cl .!= 111.94).values[1]     --> false
        @fact (111.94 .> cl).values[1]      --> false
        @fact (111.94 .< cl).values[1]      --> false
        @fact (111.94 .>= cl).values[1]     --> true
        @fact (111.94 .<= cl).values[1]     --> true
        @fact (111.94 .== cl).values[1]     --> true
        @fact (111.94 .!= cl).values[1]     --> false
        @fact (ohlc .> 111.94).values[1,:]  --> [false, true, false, false]
        @fact (ohlc .< 111.94).values[1,:]  --> [true, false, true, false]
        @fact (ohlc .>= 111.94).values[1,:] --> [false, true, false, true]
        @fact (ohlc .<= 111.94).values[1,:] --> [true, false, true, true]
        @fact (ohlc .== 111.94).values[1,:] --> [false, false, false, true]
        @fact (ohlc .!= 111.94).values[1,:] --> [true, true, true, false]
        @fact (111.94 .> ohlc).values[1,:]  --> [true, false, true, false]
        @fact (111.94 .< ohlc).values[1,:]  --> [false, true, false, false]
        @fact (111.94 .>= ohlc).values[1,:] --> [true, false, true, true]
        @fact (111.94 .<= ohlc).values[1,:] --> [false, true, false, true]
        @fact (111.94 .== ohlc).values[1,:] --> [false, false, false, true]
        @fact (111.94 .!= ohlc).values[1,:] --> [true, true, true, false]
    end

    context("correct comparison operations between TimeArray values and Bool (and viceversa)") do
        @fact ((cl .> 111.94) .== true).values[1]     --> false
        @fact ((cl .> 111.94) .!= true).values[1]     --> true
        @fact (true .== (cl .> 111.94)).values[1]     --> false
        @fact (true .!= (cl .> 111.94)).values[1]     --> true
        @fact ((ohlc .> 111.94).== true).values[1,:]  --> [false, true, false, false]
        @fact ((ohlc .> 111.94).!= true).values[1,:]  --> [true, false, true, true]
        @fact (true .== (ohlc .> 111.94)).values[1,:] --> [false, true, false, false]
        @fact (true .!= (ohlc .> 111.94)).values[1,:] --> [true, false, true, true]
    end

    context("correct comparison operations between same-column-count TimeArrays") do
        @fact (cl .> op).values[1]        --> true
        @fact (cl .< op).values[1]        --> false
        @fact (cl .<= op).values[1]       --> false
        @fact (cl .>= op).values[1]       --> true
        @fact (cl .== op).values[1]       --> false
        @fact (cl .!= op).values[1]       --> true
        @fact (ohlc .> ohlc).values[1,:]  --> [false, false, false, false]
        @fact (ohlc .< ohlc).values[1,:]  --> [false, false, false, false]
        @fact (ohlc .<= ohlc).values[1,:] --> [true, true, true, true]
        @fact (ohlc .>= ohlc).values[1,:] --> [true, true, true, true]
        @fact (ohlc .== ohlc).values[1,:] --> [true, true, true, true]
        @fact (ohlc .!= ohlc).values[1,:] --> [false, false, false, false]
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
        @fact ((cl .> 100) & true).values[1]      --> true
        @fact ((cl .> 100) | true).values[1]      --> true
        @fact ((cl .> 100) $ true).values[1]      --> false
        @fact (false & (cl .> 100)).values[1]     --> false
        @fact (false | (cl .> 100)).values[1]     --> true
        @fact (false $ (cl .> 100)).values[1]     --> true
        @fact ((ohlc .> 100) & true).values[4,:]  --> [true, true, false, false]
        @fact ((ohlc .> 100) | true).values[4,:]  --> [true, true, true, true]
        @fact ((ohlc .> 100) $ true).values[4,:]  --> [false, false, true, true]
        @fact (false & (ohlc .> 100)).values[4,:] --> [false, false, false, false]
        @fact (false | (ohlc .> 100)).values[4,:] --> [true, true, false, false]
        @fact (false $ (ohlc .> 100)).values[4,:] --> [true, true, false, false]
      end

    context("correct bitwise elementwise operations between same-column-count TimeArrays' boolean values") do
        @fact ((cl .> 100) & (cl .< 120)).values[1]       --> true
        @fact ((cl .> 100) | (cl .< 120)).values[1]       --> true
        @fact ((cl .> 100) $ (cl .< 120)).values[1]       --> false
        @fact ((ohlc .> 100) & (ohlc .< 120)).values[4,:] --> [true, true, false, false]
        @fact ((ohlc .> 100) | (ohlc .< 120)).values[4,:] --> [true, true, true, true]
        @fact ((ohlc .> 100) $ (ohlc .< 120)).values[4,:] --> [false, false, true, true]
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

facts("adding/removing missing rows works") do

    uohlc = uniformspace(ohlc[1:8])

    context("uniform spacing detection works") do
        @fact datetime1 --> uniformspaced
        @fact uohlc     --> uniformspaced
        @fact cl        --> not(uniformspaced)
        @fact ohlc      --> not(uniformspaced)
    end

    context("forcing uniform spacing works") do
        @fact length(uohlc)                               --> 10
        @fact uohlc[5].values                             --> ohlc[5].values
        @fact isequal(uohlc[6].values, [NaN NaN NaN NaN]) --> true
        @fact isequal(uohlc[7].values, [NaN NaN NaN NaN]) --> true
        @fact uohlc[8].values                             --> ohlc[6].values
    end

    context("dropnan works") do
        nohlc = TimeArray(ohlc.timestamp, copy(ohlc.values), ohlc.colnames, ohlc.meta)
        nohlc.values[7:12, 2] = NaN

        @fact dropnan(uohlc).timestamp       --> dropnan(uohlc, :all).timestamp
        @fact dropnan(uohlc).values          --> dropnan(uohlc, :all).values

        @fact dropnan(ohlc, :all).values     --> ohlc.values
        @fact dropnan(nohlc, :all).timestamp --> ohlc.timestamp
        @fact dropnan(uohlc, :all).timestamp --> ohlc[1:8].timestamp
        @fact dropnan(uohlc, :all).values    --> ohlc[1:8].values

        @fact dropnan(ohlc, :any).values     --> ohlc.values
        @fact dropnan(nohlc, :any).timestamp --> ohlc.timestamp[[1:6;13:end]]
        @fact dropnan(nohlc, :any).values    --> ohlc.values[[1:6;13:end], :]
        @fact dropnan(uohlc, :any).timestamp --> ohlc[1:8].timestamp
        @fact dropnan(uohlc, :any).values    --> ohlc[1:8].values
    end
end
