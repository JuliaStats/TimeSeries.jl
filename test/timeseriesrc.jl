using Base.Test

# this line because the const objects are not being exported
include(joinpath(dirname(@__FILE__), "..", "src/.timeseriesrc.jl"))


@testset "timeseriesrc" begin


@testset "const values are set the package defaults" begin
    @testset "DECIMALS" begin
        @test DECIMALS == 4
    end

    @testset "MISSING" begin
        @test MISSING == NAN
    end
end


@testset "const values are correct" begin
    @testset "NAN" begin
        @test NAN == "NaN"
    end

    @testset "NA" begin
        @test NA == "NA"
    end

    @testset "BLACKHOLE" begin
        @test BLACKHOLE == "\u2B24"
    end

    @testset "DOTCIRCLE" begin
        @test DOTCIRCLE == "\u25CC"
    end

    @testset "QUESTION" begin
        @test QUESTION == "\u003F"
    end
end


end  # @testset "timeseriesrc"
