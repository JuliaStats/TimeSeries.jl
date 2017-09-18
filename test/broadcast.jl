using Base.Test

using MarketData

using TimeSeries


@testset "broadcast" begin


@testset "base element-wise operators on TimeArray values" begin
    @testset "only values on intersecting Dates computed" begin
        @test isapprox((cl[1:2] ./ op[2:3]).values[1], 0.94688222)
        @test isapprox((cl[1:4] .+ op[4:7]).values[1], 201.12, atol=.01)
        @test length(cl[1:2] ./ op[2:3]) == 1
        @test length(cl[1:4] .+ op[4:7]) == 1
    end

    @testset "unary operation on TimeArray values" begin
        @test (+cl).values[1]                  == cl.values[1]
        @test (-cl).values[1]                  == -cl.values[1]
        @test (.!(cl .== op)).values[1]        == true
        @test log.(cl).values[1]               == log.(cl.values[1])
        @test sqrt.(cl).values[1]              == sqrt.(cl.values[1])
        @test (+ohlc).values[1,:]              == ohlc.values[1,:]
        @test (-ohlc).values[1,:]              == -(ohlc.values[1,:])
        @test (.!(ohlc .== ohlc)).values[1, 1] == false
        @test log.(ohlc).values[1, :]          == log.(ohlc.values[1, :])
        @test sqrt.(ohlc).values[1, :]         == sqrt.(ohlc.values[1, :])
        @test_throws DomainError sqrt.(-ohlc)
    end

    @testset "dot operation between TimeArray values and Int/Float and viceversa" begin
        @test isapprox((cl .- 100).values[1]    , 11.94, atol=.01)
        @test isapprox((cl .+ 100).values[1]    , 211.94, atol=.01)
        @test isapprox((cl .* 100).values[1]    , 11194, atol=1)
        @test isapprox((cl ./ 100).values[1]    , 1.1194, atol=.0001)
        @test isapprox((cl .^ 2).values[1]      , 12530.5636, atol=.0001)
        @test (cl .% 2).values[1] == cl.values[1] % 2
        @test isapprox((100 .- cl).values[1]    , -11.94, atol=.01)
        @test isapprox((100 .+ cl).values[1]    , 211.94, atol=.01)
        @test isapprox((100 .* cl).values[1]    , 11194, atol=.01)
        @test isapprox((100 ./ cl).values[1]    , 0.8933357155619082)
        @test (2 .^ cl).values[1]       == 4980784073277740581384811358191616
        @test (2 .% cl).values[1]       == 2
        @test (ohlc .- 100).values[1,:] == ohlc.values[1,:] .- 100
        @test (ohlc .+ 100).values[1,:] == ohlc.values[1,:] .+ 100
        @test (ohlc .* 100).values[1,:] == ohlc.values[1,:] .* 100
        @test (ohlc ./ 100).values[1,:] == ohlc.values[1,:] ./ 100
        @test (ohlc .^ 2).values[1,:]   == ohlc.values[1,:] .^ 2
        @test (ohlc .% 2).values[1,:]   == ohlc.values[1,:] .% 2
        @test (100 .- ohlc).values[1,:] == 100 .- ohlc.values[1,:]
        @test (100 .+ ohlc).values[1,:] == 100 .+ ohlc.values[1,:]
        @test (100 .* ohlc).values[1,:] == 100 .* ohlc.values[1,:]
        @test (100 ./ ohlc).values[1,:] == 100 ./ ohlc.values[1,:]
        @test (2 .^ ohlc).values[1,:]   == 2 .^ ohlc.values[1,:]
        @test (2 .% ohlc).values[1,:]   == 2 .% ohlc.values[1,:]
    end

    @testset "mathematical operations between two same-column-count TimeArrays" begin
        @test isapprox((cl .+ op).values[1], 216.82, atol=.01)
        @test isapprox((cl .- op).values[1], 7.06, atol=.01)
        @test isapprox((cl .* op).values[1], 11740.2672, atol=0.0001)
        @test isapprox((cl ./ op).values[1], 1.067315, atol=0.001)
        @test (cl .% op).values                                 == cl.values .% op.values
        @test (cl .^ op).values                                 == cl.values .^ op.values
        @test (cl .* (cl.> 200)).values                         == cl.values .* (cl.values .> 200)
        @test (round.(cl) .* cl).values                         == round.(Int, cl.values) .* cl.values
        @test (ohlc .+ ohlc).values                             == ohlc.values .+ ohlc.values
        @test (ohlc .- ohlc).values                             == ohlc.values .- ohlc.values
        @test (ohlc .* ohlc).values                             == ohlc.values .* ohlc.values
        @test (ohlc ./ ohlc).values                             == ohlc.values ./ ohlc.values
        @test (ohlc .% ohlc).values                             == ohlc.values .% ohlc.values
        @test (ohlc .^ ohlc).values                             == ohlc.values .^ ohlc.values
        @test (ohlc .* (ohlc .> 200)).values                    == ohlc.values .* (ohlc.values .> 200)
        @test (round.(ohlc) .* ohlc).values                     == round.(Int, ohlc.values) .* ohlc.values
    end

    @testset "broadcasted mathematical operations between different-column-count TimeArrays" begin
        @test (ohlc .+ cl).values                             == ohlc.values .+ cl.values
        @test (ohlc .- cl).values                             == ohlc.values .- cl.values
        @test (ohlc .* cl).values                             == ohlc.values .* cl.values
        @test (ohlc ./ cl).values                             == ohlc.values ./ cl.values
        @test (ohlc .% cl).values                             == ohlc.values .% cl.values
        @test (ohlc .^ cl).values                             == ohlc.values .^ cl.values
        @test (ohlc .* (cl.> 200)).values                     == ohlc.values .* (cl.values .> 200)
        @test (round.(ohlc) .* cl).values                     == round.(Int, ohlc.values) .* cl.values
        @test (cl .+ ohlc).values                             == cl.values .+ ohlc.values
        @test (cl .- ohlc).values                             == cl.values .- ohlc.values
        @test (cl .* ohlc).values                             == cl.values .* ohlc.values
        @test (cl ./ ohlc).values                             == cl.values ./ ohlc.values
        @test (cl .% ohlc).values                             == cl.values .% ohlc.values
        @test (cl .^ ohlc).values                             == cl.values .^ ohlc.values
        @test (cl .* (ohlc .> 200)).values                    == cl.values .* (ohlc.values .> 200)
        @test (round.(cl) .* ohlc).values                     == round.(Int, cl.values) .* ohlc.values
        # One array must have a single column
        @test_throws DimensionMismatch (ohlc["Open", "Close"] .+ ohlc)
    end

    @testset "comparison operations between TimeArray values and Int/Float (and viceversa)" begin
        @test (cl .> 111.94).values[1]      == false
        @test (cl .< 111.94).values[1]      == false
        @test (cl .>= 111.94).values[1]     == true
        @test (cl .<= 111.94).values[1]     == true
        @test (cl .== 111.94).values[1]     == true
        @test (cl .!= 111.94).values[1]     == false
        @test (111.94 .> cl).values[1]      == false
        @test (111.94 .< cl).values[1]      == false
        @test (111.94 .>= cl).values[1]     == true
        @test (111.94 .<= cl).values[1]     == true
        @test (111.94 .== cl).values[1]     == true
        @test (111.94 .!= cl).values[1]     == false
        @test (ohlc .> 111.94).values[1,:]  == [false, true, false, false]
        @test (ohlc .< 111.94).values[1,:]  == [true, false, true, false]
        @test (ohlc .>= 111.94).values[1,:] == [false, true, false, true]
        @test (ohlc .<= 111.94).values[1,:] == [true, false, true, true]
        @test (ohlc .== 111.94).values[1,:] == [false, false, false, true]
        @test (ohlc .!= 111.94).values[1,:] == [true, true, true, false]
        @test (111.94 .> ohlc).values[1,:]  == [true, false, true, false]
        @test (111.94 .< ohlc).values[1,:]  == [false, true, false, false]
        @test (111.94 .>= ohlc).values[1,:] == [true, false, true, true]
        @test (111.94 .<= ohlc).values[1,:] == [false, true, false, true]
        @test (111.94 .== ohlc).values[1,:] == [false, false, false, true]
        @test (111.94 .!= ohlc).values[1,:] == [true, true, true, false]
    end

    @testset "comparison operations between TimeArray values and Bool (and viceversa)" begin
        @test ((cl .> 111.94) .== true).values[1]     == false
        @test ((cl .> 111.94) .!= true).values[1]     == true
        @test (true .== (cl .> 111.94)).values[1]     == false
        @test (true .!= (cl .> 111.94)).values[1]     == true
        @test ((ohlc .> 111.94).== true).values[1,:]  == [false, true, false, false]
        @test ((ohlc .> 111.94).!= true).values[1,:]  == [true, false, true, true]
        @test (true .== (ohlc .> 111.94)).values[1,:] == [false, true, false, false]
        @test (true .!= (ohlc .> 111.94)).values[1,:] == [true, false, true, true]
    end

    @testset "comparison operations between same-column-count TimeArrays" begin
        @test (cl .> op).values[1]        == true
        @test (cl .< op).values[1]        == false
        @test (cl .<= op).values[1]       == false
        @test (cl .>= op).values[1]       == true
        @test (cl .== op).values[1]       == false
        @test (cl .!= op).values[1]       == true
        @test (ohlc .> ohlc).values[1,:]  == [false, false, false, false]
        @test (ohlc .< ohlc).values[1,:]  == [false, false, false, false]
        @test (ohlc .<= ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .>= ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .== ohlc).values[1,:] == [true, true, true, true]
        @test (ohlc .!= ohlc).values[1,:] == [false, false, false, false]
    end

    @testset "comparison operations between different-column-count TimeArrays" begin
        @test (ohlc .> cl).values  == (ohlc.values .> cl.values)
        @test (ohlc .< cl).values  == (ohlc.values .< cl.values)
        @test (ohlc .>= cl).values == (ohlc.values .>= cl.values)
        @test (ohlc .<= cl).values == (ohlc.values .<= cl.values)
        @test (ohlc .== cl).values == (ohlc.values .== cl.values)
        @test (ohlc .!= cl).values == (ohlc.values .!= cl.values)
        @test (cl .> ohlc).values  == (cl.values .> ohlc.values)
        @test (cl .< ohlc).values  == (cl.values .< ohlc.values)
        @test (cl .>= ohlc).values == (cl.values .>= ohlc.values)
        @test (cl .<= ohlc).values == (cl.values .<= ohlc.values)
        @test (cl .== ohlc).values == (cl.values .== ohlc.values)
        @test (cl .!= ohlc).values == (cl.values .!= ohlc.values)
        # One array must have a single column
        @test_throws DimensionMismatch (ohlc["Open", "Close"] .== ohlc)
    end

    @testset "bitwise elementwise operations between bool and TimeArrays' values" begin
        @test ((cl .> 100) .& true).values[1]      == true
        @test ((cl .> 100) .| true).values[1]      == true
        @test ((cl .> 100) .⊻ true).values[1]      == false
        @test (false .& (cl .> 100)).values[1]     == false
        @test (false .| (cl .> 100)).values[1]     == true
        @test (false .⊻ (cl .> 100)).values[1]     == true
        @test ((ohlc .> 100) .& true).values[4,:]  == [true, true, false, false]
        @test ((ohlc .> 100) .| true).values[4,:]  == [true, true, true, true]
        @test ((ohlc .> 100) .⊻ true).values[4,:]  == [false, false, true, true]
        @test (false .& (ohlc .> 100)).values[4,:] == [false, false, false, false]
        @test (false .| (ohlc .> 100)).values[4,:] == [true, true, false, false]
        @test (false .⊻ (ohlc .> 100)).values[4,:] == [true, true, false, false]
      end

    @testset "bitwise elementwise operations between same-column-count TimeArrays' boolean values" begin
        @test ((cl .> 100) .& (cl .< 120)).values[1]       == true
        @test ((cl .> 100) .| (cl .< 120)).values[1]       == true
        @test ((cl .> 100) .⊻ (cl .< 120)).values[1]       == false
        @test ((ohlc .> 100) .& (ohlc .< 120)).values[4,:] == [true, true, false, false]
        @test ((ohlc .> 100) .| (ohlc .< 120)).values[4,:] == [true, true, true, true]
        @test ((ohlc .> 100) .⊻ (ohlc .< 120)).values[4,:] == [false, false, true, true]
        @test ((ohlc .> 100) .⊻ (cl .< 120)).values[4,:]   == [false, false, true, true]
    end
end


@testset "dot call auto-fusion" begin
    @testset "single TimeArray" begin
        let ta = sin.(log.(2, op))
            @test ta.colnames == ["Open"]
            @test ta.timestamp == op.timestamp
            @test ta.meta == op.meta
            @test ta.values[1] == sin(log(2, op.values[1]))
            @test ta.values[end] == sin(log(2, op.values[end]))
        end

        f(x, c) = x + c
        let ta = f.(cl, 42)
            @test ta.colnames == ["Close"]
            @test ta.timestamp == cl.timestamp
            @test ta.meta == cl.meta
            @test ta.values[1] == cl.values[1] + 42
            @test ta.values[end] == cl.values[end] + 42
        end

        let ta = sin.(log.(2, ohlc))
            @test ta.colnames == ["Open", "High", "Low", "Close"]
            @test ta.timestamp == ohlc.timestamp
            @test ta.meta == ohlc.meta

            @test ta.values[1, 1] == sin(log(2, ohlc.values[1, 1]))
            @test ta.values[1, 2] == sin(log(2, ohlc.values[1, 2]))
            @test ta.values[1, 3] == sin(log(2, ohlc.values[1, 3]))
            @test ta.values[1, 4] == sin(log(2, ohlc.values[1, 4]))

            @test ta.values[end, 1] == sin(log(2, ohlc.values[end, 1]))
            @test ta.values[end, 2] == sin(log(2, ohlc.values[end, 2]))
            @test ta.values[end, 3] == sin(log(2, ohlc.values[end, 3]))
            @test ta.values[end, 4] == sin(log(2, ohlc.values[end, 4]))
        end
    end

    @testset "TimeArray and Array" begin
        let ta = cl[1:4] .+ [1, 2, 3, 4]
            @test ta.colnames == ["Close"]
            @test ta.timestamp == cl.timestamp[1:4]
            @test ta.meta == cl.meta

            @test ta.values[1] == cl.values[1] + 1
            @test ta.values[2] == cl.values[2] + 2
            @test ta.values[3] == cl.values[3] + 3
            @test ta.values[4] == cl.values[4] + 4
        end

        let ta = ohlc[1:4] .+ [1, 2, 3, 4]
            @test ta.colnames == ["Open", "High", "Low", "Close"]
            @test ta.timestamp == ohlc.timestamp[1:4]
            @test ta.meta == ohlc.meta

            @test ta.values[1, 1] == ohlc.values[1, 1] + 1
            @test ta.values[1, 2] == ohlc.values[1, 2] + 1
            @test ta.values[1, 3] == ohlc.values[1, 3] + 1
            @test ta.values[1, 4] == ohlc.values[1, 4] + 1
        end

        let arr = [1, 2, 3, 4]
            @test_throws DimensionMismatch cl .+ arr
        end
    end

    @testset "custom function" begin
        let f(x, y, c) = x - y + c, ta = f.(op, cl, 42)
            @test ta.colnames == ["Open_Close"]
            @test ta.timestamp == cl.timestamp
            @test ta.timestamp == op.timestamp
            @test ta.meta == op.meta
            @test ta.values[1] == op.values[1] - cl.values[1] + 42
            @test ta.values[end] == op.values[end] - cl.values[end] + 42
        end
    end
end  # @testset "dot call auto-fusion"


end  # @testset "broadcast"
