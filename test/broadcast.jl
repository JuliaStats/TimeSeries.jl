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


#TODO: add test cases of non-standard function on dot-call


end  # @testset "broadcast"
