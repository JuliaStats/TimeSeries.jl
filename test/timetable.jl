using Test
using Dates

using TimeSeries

@testset "timetable" begin


@testset "getindex" begin
    @testset "int -> row" begin
        g = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        tt = TimeTable(g; a = [1, 2  ,  3, 5, 42, -10],
                          b = [4, 252, 14, 2, 1 ,  6.])

        r = tt[1]
        @test r[1] == 1
        @test r[2] == g[1]
        @test r[3] == [1, 4]

        r = tt[6]
        @test r[1] == 6
        @test r[2] == g[6]
        @test r[3] == [-10, 6]

        r = tt[end]
        @test r[1] == 10
        @test r[2] == g[10]
        @test isequal(r[3], [missing, missing])
    end
end


end  # @testset "timetable"
