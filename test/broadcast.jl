using Test

using MarketData

using TimeSeries


@testset "broadcast" begin


@testset "base element-wise operators on TimeArray values" begin
    @testset "only values on intersecting Dates computed" begin
        let
            ta = cl[1:2] ./ op[2:3]
            @test values(ta)[1]  ≈ 0.94688222
            @test length(ta)    == 1
        end

        let
            ta = cl[1:4] .+ op[4:7]
            @test values(ta)[1]  ≈ 201.12 atol=.01
            @test length(ta)    == 1
        end
    end

    @testset "unary operation on TimeArray values" begin
        @test values(+cl)[1]                  == values(cl)[1]
        @test values(-cl)[1]                  == -values(cl)[1]
        @test values(.!(cl .== op))[1]        == true
        @test values(log.(cl))[1]             == log.(values(cl)[1])
        @test values(sqrt.(cl))[1]            == sqrt.(values(cl)[1])
        @test values(+ohlc)[1, :]             == values(ohlc)[1,:]
        @test values(-ohlc)[1, :]             == -(values(ohlc)[1,:])
        @test values(.!(ohlc .== ohlc))[1, 1] == false
        @test values(log.(ohlc))[1, :]        == log.(values(ohlc)[1, :])
        @test values(sqrt.(ohlc))[1, :]       == sqrt.(values(ohlc)[1, :])
        @test_throws DomainError sqrt.(-ohlc)
    end

    @testset "dot operation between TimeArray values and Int/Float and viceversa" begin
        @test values(cl .- 100)[1]      ≈ 11.94      atol=.01
        @test values(cl .+ 100)[1]      ≈ 211.94     atol=.01
        @test values(cl .* 100)[1]      ≈ 11194      atol=1
        @test values(cl ./ 100)[1]      ≈ 1.1194     atol=.0001
        @test values(cl .^ 2)[1]        ≈ 12530.5636 atol=.0001
        @test values(cl .% 2)[1]       == values(cl)[1] % 2
        @test values(100 .- cl)[1]      ≈ -11.94 atol=.01
        @test values(100 .+ cl)[1]      ≈ 211.94 atol=.01
        @test values(100 .* cl)[1]      ≈ 11194  atol=.01
        @test values(100 ./ cl)[1]      ≈ 0.8933357155619082
        @test values(2 .^ cl)[1]       == 4980784073277740581384811358191616
        @test values(2 .% cl)[1]       == 2
        @test values(ohlc .- 100)[1,:] == values(ohlc)[1,:] .- 100
        @test values(ohlc .+ 100)[1,:] == values(ohlc)[1,:] .+ 100
        @test values(ohlc .* 100)[1,:] == values(ohlc)[1,:] .* 100
        @test values(ohlc ./ 100)[1,:] == values(ohlc)[1,:] ./ 100
        @test values(ohlc .^ 2)[1,:]   == values(ohlc)[1,:] .^ 2
        @test values(ohlc .% 2)[1,:]   == values(ohlc)[1,:] .% 2
        @test values(100 .- ohlc)[1,:] == 100 .- values(ohlc)[1,:]
        @test values(100 .+ ohlc)[1,:] == 100 .+ values(ohlc)[1,:]
        @test values(100 .* ohlc)[1,:] == 100 .* values(ohlc)[1,:]
        @test values(100 ./ ohlc)[1,:] == 100 ./ values(ohlc)[1,:]
        @test values(2 .^ ohlc)[1,:]   == 2 .^ values(ohlc)[1,:]
        @test values(2 .% ohlc)[1,:]   == 2 .% values(ohlc)[1,:]
    end

    @testset "mathematical operations between two same-column-count TimeArrays" begin
        @test values(cl .+ op)[1]            ≈ 216.82     atol=.01
        @test values(cl .- op)[1]            ≈ 7.06       atol=.01
        @test values(cl .* op)[1]            ≈ 11740.2672 atol=0.0001
        @test values(cl ./ op)[1]            ≈ 1.067315   atol=0.001
        @test values(cl .% op)              == values(cl) .% values(op)
        @test values(cl .^ op)              == values(cl) .^ values(op)
        @test values(cl .* (cl.> 200))      == values(cl) .* (values(cl) .> 200)
        @test values(round.(cl) .* cl)      == round.(Int, values(cl)) .* values(cl)
        @test values(ohlc .+ ohlc)          == values(ohlc) .+ values(ohlc)
        @test values(ohlc .- ohlc)          == values(ohlc) .- values(ohlc)
        @test values(ohlc .* ohlc)          == values(ohlc) .* values(ohlc)
        @test values(ohlc ./ ohlc)          == values(ohlc) ./ values(ohlc)
        @test values(ohlc .% ohlc)          == values(ohlc) .% values(ohlc)
        @test values(ohlc .^ ohlc)          == values(ohlc) .^ values(ohlc)
        @test values(ohlc .* (ohlc .> 200)) == values(ohlc) .* (values(ohlc) .> 200)
        @test values(round.(ohlc) .* ohlc)  == round.(Int, values(ohlc)) .* values(ohlc)
    end

    @testset "broadcasted mathematical operations between different-column-count TimeArrays" begin
        @test values(ohlc .+ cl)          == values(ohlc) .+ values(cl)
        @test values(ohlc .- cl)          == values(ohlc) .- values(cl)
        @test values(ohlc .* cl)          == values(ohlc) .* values(cl)
        @test values(ohlc ./ cl)          == values(ohlc) ./ values(cl)
        @test values(ohlc .% cl)          == values(ohlc) .% values(cl)
        @test values(ohlc .^ cl)          == values(ohlc) .^ values(cl)
        @test values(ohlc .* (cl.> 200))  == values(ohlc) .* (values(cl) .> 200)
        @test values(round.(ohlc) .* cl)  == round.(Int, values(ohlc)) .* values(cl)
        @test values(cl .+ ohlc)          == values(cl) .+ values(ohlc)
        @test values(cl .- ohlc)          == values(cl) .- values(ohlc)
        @test values(cl .* ohlc)          == values(cl) .* values(ohlc)
        @test values(cl ./ ohlc)          == values(cl) ./ values(ohlc)
        @test values(cl .% ohlc)          == values(cl) .% values(ohlc)
        @test values(cl .^ ohlc)          == values(cl) .^ values(ohlc)
        @test values(cl .* (ohlc .> 200)) == values(cl) .* (values(ohlc) .> 200)
        @test values(round.(cl) .* ohlc)  == round.(Int, values(cl)) .* values(ohlc)
        # One array must have a single column
        @test_throws DimensionMismatch (ohlc[:Open, :Close] .+ ohlc)
    end

    @testset "comparison operations between TimeArray values and Int/Float (and viceversa)" begin
        @test values(cl .> 111.94)[1]      == false
        @test values(cl .< 111.94)[1]      == false
        @test values(cl .>= 111.94)[1]     == true
        @test values(cl .<= 111.94)[1]     == true
        @test values(cl .== 111.94)[1]     == true
        @test values(cl .!= 111.94)[1]     == false
        @test values(111.94 .> cl)[1]      == false
        @test values(111.94 .< cl)[1]      == false
        @test values(111.94 .>= cl)[1]     == true
        @test values(111.94 .<= cl)[1]     == true
        @test values(111.94 .== cl)[1]     == true
        @test values(111.94 .!= cl)[1]     == false
        @test values(ohlc .> 111.94)[1,:]  == [false, true, false, false]
        @test values(ohlc .< 111.94)[1,:]  == [true, false, true, false]
        @test values(ohlc .>= 111.94)[1,:] == [false, true, false, true]
        @test values(ohlc .<= 111.94)[1,:] == [true, false, true, true]
        @test values(ohlc .== 111.94)[1,:] == [false, false, false, true]
        @test values(ohlc .!= 111.94)[1,:] == [true, true, true, false]
        @test values(111.94 .> ohlc)[1,:]  == [true, false, true, false]
        @test values(111.94 .< ohlc)[1,:]  == [false, true, false, false]
        @test values(111.94 .>= ohlc)[1,:] == [true, false, true, true]
        @test values(111.94 .<= ohlc)[1,:] == [false, true, false, true]
        @test values(111.94 .== ohlc)[1,:] == [false, false, false, true]
        @test values(111.94 .!= ohlc)[1,:] == [true, true, true, false]
    end

    @testset "comparison operations between TimeArray values and Bool (and viceversa)" begin
        @test values((cl .> 111.94) .== true)[1]     == false
        @test values((cl .> 111.94) .!= true)[1]     == true
        @test values(true .== (cl .> 111.94))[1]     == false
        @test values(true .!= (cl .> 111.94))[1]     == true
        @test values((ohlc .> 111.94).== true)[1,:]  == [false, true, false, false]
        @test values((ohlc .> 111.94).!= true)[1,:]  == [true, false, true, true]
        @test values(true .== (ohlc .> 111.94))[1,:] == [false, true, false, false]
        @test values(true .!= (ohlc .> 111.94))[1,:] == [true, false, true, true]
    end

    @testset "comparison operations between same-column-count TimeArrays" begin
        @test values(cl .> op)[1]        == true
        @test values(cl .< op)[1]        == false
        @test values(cl .<= op)[1]       == false
        @test values(cl .>= op)[1]       == true
        @test values(cl .== op)[1]       == false
        @test values(cl .!= op)[1]       == true
        @test values(ohlc .> ohlc)[1,:]  == [false, false, false, false]
        @test values(ohlc .< ohlc)[1,:]  == [false, false, false, false]
        @test values(ohlc .<= ohlc)[1,:] == [true, true, true, true]
        @test values(ohlc .>= ohlc)[1,:] == [true, true, true, true]
        @test values(ohlc .== ohlc)[1,:] == [true, true, true, true]
        @test values(ohlc .!= ohlc)[1,:] == [false, false, false, false]
    end

    @testset "comparison operations between different-column-count TimeArrays" begin
        @test values(ohlc .> cl)  == (values(ohlc) .> values(cl))
        @test values(ohlc .< cl)  == (values(ohlc) .< values(cl))
        @test values(ohlc .>= cl) == (values(ohlc) .>= values(cl))
        @test values(ohlc .<= cl) == (values(ohlc) .<= values(cl))
        @test values(ohlc .== cl) == (values(ohlc) .== values(cl))
        @test values(ohlc .!= cl) == (values(ohlc) .!= values(cl))
        @test values(cl .> ohlc)  == (values(cl) .> values(ohlc))
        @test values(cl .< ohlc)  == (values(cl) .< values(ohlc))
        @test values(cl .>= ohlc) == (values(cl) .>= values(ohlc))
        @test values(cl .<= ohlc) == (values(cl) .<= values(ohlc))
        @test values(cl .== ohlc) == (values(cl) .== values(ohlc))
        @test values(cl .!= ohlc) == (values(cl) .!= values(ohlc))
        # One array must have a single column
        @test_throws DimensionMismatch (ohlc[:Open, :Close] .== ohlc)
    end

    @testset "bitwise elementwise operations between bool and TimeArrays' values" begin
        @test values((cl .> 100) .& true)[1]      == true
        @test values((cl .> 100) .| true)[1]      == true
        @test values((cl .> 100) .⊻ true)[1]      == false
        @test values(false .& (cl .> 100))[1]     == false
        @test values(false .| (cl .> 100))[1]     == true
        @test values(false .⊻ (cl .> 100))[1]     == true
        @test values((ohlc .> 100) .& true)[4,:]  == [true, true, false, false]
        @test values((ohlc .> 100) .| true)[4,:]  == [true, true, true, true]
        @test values((ohlc .> 100) .⊻ true)[4,:]  == [false, false, true, true]
        @test values(false .& (ohlc .> 100))[4,:] == [false, false, false, false]
        @test values(false .| (ohlc .> 100))[4,:] == [true, true, false, false]
        @test values(false .⊻ (ohlc .> 100))[4,:] == [true, true, false, false]
      end

    @testset "bitwise elementwise operations between same-column-count TimeArrays' boolean values" begin
        @test values((cl .> 100) .& (cl .< 120))[1]       == true
        @test values((cl .> 100) .| (cl .< 120))[1]       == true
        @test values((cl .> 100) .⊻ (cl .< 120))[1]       == false
        @test values((ohlc .> 100) .& (ohlc .< 120))[4,:] == [true, true, false, false]
        @test values((ohlc .> 100) .| (ohlc .< 120))[4,:] == [true, true, true, true]
        @test values((ohlc .> 100) .⊻ (ohlc .< 120))[4,:] == [false, false, true, true]
        @test values((ohlc .> 100) .⊻ (cl .< 120))[4,:]   == [false, false, true, true]
    end
end


@testset "dot call auto-fusion" begin
    @testset "single TimeArray" begin
        let ta = sin.(log.(2, op))
            @test colnames(ta) == [:Open]
            @test timestamp(ta) == timestamp(op)
            @test meta(ta) == meta(op)
            @test values(ta)[1] == sin(log(2, values(op)[1]))
            @test values(ta)[end] == sin(log(2, values(op)[end]))
        end

        f(x, c) = x + c
        let ta = f.(cl, 42)
            @test colnames(ta) == [:Close]
            @test timestamp(ta) == timestamp(cl)
            @test meta(ta) == meta(cl)
            @test values(ta)[1] == values(cl)[1] + 42
            @test values(ta)[end] == values(cl)[end] + 42
        end

        let ta = sin.(log.(2, ohlc))
            @test colnames(ta) == [:Open, :High, :Low, :Close]
            @test timestamp(ta) == timestamp(ohlc)
            @test meta(ta) == meta(ohlc)

            @test values(ta)[1, 1] == sin(log(2, values(ohlc)[1, 1]))
            @test values(ta)[1, 2] == sin(log(2, values(ohlc)[1, 2]))
            @test values(ta)[1, 3] == sin(log(2, values(ohlc)[1, 3]))
            @test values(ta)[1, 4] == sin(log(2, values(ohlc)[1, 4]))

            @test values(ta)[end, 1] == sin(log(2, values(ohlc)[end, 1]))
            @test values(ta)[end, 2] == sin(log(2, values(ohlc)[end, 2]))
            @test values(ta)[end, 3] == sin(log(2, values(ohlc)[end, 3]))
            @test values(ta)[end, 4] == sin(log(2, values(ohlc)[end, 4]))
        end
    end

    @testset "TimeArray and Array" begin
        let ta = cl[1:4] .+ [1, 2, 3, 4]
            @test colnames(ta) == [:Close]
            @test timestamp(ta) == timestamp(cl)[1:4]
            @test meta(ta) == meta(cl)

            @test values(ta)[1] == values(cl)[1] + 1
            @test values(ta)[2] == values(cl)[2] + 2
            @test values(ta)[3] == values(cl)[3] + 3
            @test values(ta)[4] == values(cl)[4] + 4
        end

        let ta = ohlc[1:4] .+ [1, 2, 3, 4]
            @test colnames(ta) == [:Open, :High, :Low, :Close]
            @test timestamp(ta) == timestamp(ohlc)[1:4]
            @test meta(ta) == meta(ohlc)

            @test values(ta)[1, 1] == values(ohlc)[1, 1] + 1
            @test values(ta)[1, 2] == values(ohlc)[1, 2] + 1
            @test values(ta)[1, 3] == values(ohlc)[1, 3] + 1
            @test values(ta)[1, 4] == values(ohlc)[1, 4] + 1
        end

        let arr = [1, 2, 3, 4]
            @test_throws DimensionMismatch cl .+ arr
        end
    end

    @testset "custom function" begin
        let f(x, y, c) = x - y + c, ta = f.(op, cl, 42)
            @test colnames(ta) == [:Open_Close]
            @test timestamp(ta) == timestamp(cl)
            @test timestamp(ta) == timestamp(op)
            @test meta(ta) == meta(op)
            @test values(ta)[1] == values(op)[1] - values(cl)[1] + 42
            @test values(ta)[end] == values(op)[end] - values(cl)[end] + 42
        end
    end

    @testset "broadcast 2D TimeArray" begin
        let A = reshape(values(cl), 500, 1)  # 2D, dim -> 500×1
          ta = TimeArray(timestamp(cl), A) .+ ohlc
          @test length(colnames(ta)) == 4
          @test timestamp(ta) == timestamp(cl)
        end
    end
end  # @testset "dot call auto-fusion"


end  # @testset "broadcast"
