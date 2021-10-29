using Base.Iterators
using Dates
using IntervalSets
using Test

using TimeSeries.TimeAxis


@static if VERSION < v"1.1"
    isnothing(::Any)     = false
    isnothing(::Nothing) = true
end


@testset "TimeGrid" begin


@testset "iterator" begin
    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 3)
        @test [i for i ∈ tg] == [
            DateTime(2021, 1, 1, 0,  0),
            DateTime(2021, 1, 1, 0, 15),
            DateTime(2021, 1, 1, 0 ,30),
        ]

        # TODO: @inferred
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @test [i for i ∈ take(tg, 3)] == [
            DateTime(2021, 1, 1, 0,  0),
            DateTime(2021, 1, 1, 0, 15),
            DateTime(2021, 1, 1, 0 ,30),
        ]
        @test length([i for i ∈ take(tg, 4202)]) == 4202
    end
end  # @testset "iterator"


@testset "getindex" begin
    @testset "by index, finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "getindex(i, ::Int) :: $(typeof(tg))"

        @test tg[1]   == tg.o
        @test tg[2]   == DateTime(2021, 1, 1, 0, 15)
        @test tg[end] == tg.o + 9 * Minute(15)
        @test_throws BoundsError tg[0]
        @test_throws BoundsError tg[11]
        @test_throws BoundsError tg[-42]
    end

    @testset "by index, infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "getindex(i, ::Int) :: $(typeof(tg))"

        @test tg[1] == tg.o
        @test tg[2] == DateTime(2021, 1, 1, 0, 15)
        @test_throws BoundsError tg[0]
        @test_throws BoundsError tg[-42]
    end

    @testset "by time, finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "getindex(i, ::TimeType) :: $(typeof(tg))"

        @test tg[tg.o]    == 1
        @test tg[tg[2]]   == 2
        @test tg[tg[end]] == 10

        @test_throws KeyError tg[DateTime(2019, 1, 1)]
        @test_throws KeyError tg[DateTime(2022, 1, 1)]
    end

    @testset "by time, infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "getindex(i, ::TimeType) :: $(typeof(tg))"

        @test tg[tg.o]    == 1
        @test tg[tg[2]]   == 2
        @test tg[tg[42]]  == 42

        @test_throws KeyError tg[DateTime(2019, 1, 1)]
    end
end   # @testset "getindex"


@testset "find*" begin
    # TODO: test cases for benchmarking against tg and vg

    function test_findprev(tg::TimeGrid, vg)
        for f ∈ [≤, <, ≥, >, ==, isequal]
            @info "findprev :: $(typeof(tg)) :: f -> $f"

            @test findprev(f(DateTime(2021, 1, 1, 0, 33)), tg, 10) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 33)), vg, 10)
            @test findprev(f(DateTime(2021, 1, 1, 0, 30)), tg, 10) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 30)), vg, 10)
            @test findprev(f(DateTime(2021, 1, 1, 0, 29)), tg, 10) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 29)), vg, 10)
            @test findprev(f(DateTime(2021, 1, 1)),        tg, 10) ==
                  findprev(f(DateTime(2021, 1, 1)),        vg, 10)
            @test findprev(f(DateTime(2021, 1, 1, 2, 15)), tg, 10) ==
                  findprev(f(DateTime(2021, 1, 1, 2, 15)), vg, 10)

            @test findprev(f(DateTime(2021, 1, 1, 0, 33)), tg,  3) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 33)), vg,  3)
            @test findprev(f(DateTime(2021, 1, 1, 0, 30)), tg,  3) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 30)), vg,  3)
            @test findprev(f(DateTime(2021, 1, 1, 0, 29)), tg,  3) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 29)), vg,  3)

            @test findprev(f(DateTime(2021, 1, 1, 0, 33)), tg,  2) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 33)), vg,  2)
            @test findprev(f(DateTime(2021, 1, 1, 0, 30)), tg,  2) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 30)), vg,  2)
            @test findprev(f(DateTime(2021, 1, 1, 0, 29)), tg,  2) ==
                  findprev(f(DateTime(2021, 1, 1, 0, 29)), vg,  2)

            @test findprev(f(Date(2019, 1, 1)), tg,  2) ==
                  findprev(f(Date(2019, 1, 1)), vg,  2)
            @test findprev(f(Date(2019, 1, 1)), tg,  2) ==
                  findprev(f(Date(2019, 1, 1)), vg,  2)
            @test findprev(f(Date(2019, 1, 1)), tg,  2) ==
                  findprev(f(Date(2019, 1, 1)), vg,  2)

            @test_throws BoundsError findprev(f(DateTime(2021, 1, 1, 0, 33)), tg, 0)
            @test_throws BoundsError findprev(f(DateTime(2021, 1, 1, 0, 33)), tg, -1)
            if Base.haslength(tg)
                @test_throws BoundsError findprev(f(DateTime(2021, 1, 1, 0, 33)), tg, 42)
            end
        end

        # NearestNeighbors
        @info "findprev :: $(typeof(tg)) :: f -> nns :: d -> :both"

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(15), direction = :both)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(2), direction = :both)
        @test findprev(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(3), direction = :both)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 48), radius = Minute(33), direction = :both)
        @test findprev(nn, tg, 10) == 4
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == 2
        @test findprev(nn, tg, 1)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 22, 30), radius = Minute(15), direction = :both)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == 2
        @test findprev(nn, tg, 1)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :both)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :both)
        @test findprev(nn, tg, 10) == 1
        @test findprev(nn, tg, 1)  == 1

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :both)
        @test findprev(nn, tg, 10) == 1
        @test findprev(nn, tg, 1)  == 1

        nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :both)
        @test findprev(nn, tg, 10) == 10
        @test findprev(nn, tg, 9)  == nothing

        @info "findprev :: $(typeof(tg)) :: f -> nns :: d -> :forward"

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(15), direction = :forward)
        @test findprev(nn, tg, 10) == 4
        @test findprev(nn, tg, 4)  == 4
        @test findprev(nn, tg, 3)  == nothing
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(3), direction = :forward)
        @test findprev(nn, tg, 10)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(3), direction = :forward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 48), radius = Minute(33), direction = :forward)
        @test findprev(nn, tg, 10) == 5
        @test findprev(nn, tg, 5)  == 5
        @test findprev(nn, tg, 4)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 22, 30), radius = Minute(15), direction = :forward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing
        @test findprev(nn, tg, 1)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :forward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :forward)
        @test findprev(nn, tg, 10) == 1
        @test findprev(nn, tg, 1)  == 1

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :forward)
        @test findprev(nn, tg, 10) == 1
        @test findprev(nn, tg, 1)  == 1

        nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :forward)
        @test findprev(nn, tg, 10) == nothing

        @info "findprev :: $(typeof(tg)) :: f -> nns :: d -> :backward"

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 4)  == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(3), direction = :backward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(3), direction = :backward)
        @test findprev(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 48), radius = Minute(33), direction = :backward)
        @test findprev(nn, tg, 10) == 4
        @test findprev(nn, tg, 4)  == 4
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == 2
        @test findprev(nn, tg, 1)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 22, 30), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 10) == 2
        @test findprev(nn, tg, 3)  == 2
        @test findprev(nn, tg, 1)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :backward)
        @test findprev(nn, tg, 10) == 3
        @test findprev(nn, tg, 3)  == 3
        @test findprev(nn, tg, 2)  == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 1) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 1) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 10) == 10
        @test findprev(nn, tg, 9)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 2, 27), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 10) == 10
        @test findprev(nn, tg, 9)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 2, 33), radius = Minute(15), direction = :backward)
        @test findprev(nn, tg, 10) == nothing
    end  # function test_findprev

    @testset "findprev finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        vg = collect(tg)
        test_findprev(tg, vg)
    end

    @testset "findprev infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        vg = collect(Iterators.take(tg, 10))
        test_findprev(tg, vg)
    end

    function test_findnext(tg::TimeGrid, vg)
        for f ∈ [≤, <, ≥, >, ==, isequal]
            @info "findnext :: $(typeof(tg)) :: f -> $f"

            @test findnext(f(DateTime(2021, 1, 1, 0, 33)), tg,  1) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 33)), vg,  1)
            @test findnext(f(DateTime(2021, 1, 1, 0, 30)), tg,  1) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 30)), vg,  1)
            @test findnext(f(DateTime(2021, 1, 1, 0, 29)), tg,  1) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 29)), vg,  1)
            @test findnext(f(DateTime(2021, 1, 1)),        tg,  1) ==
                  findnext(f(DateTime(2021, 1, 1)),        vg,  1)
            @test findnext(f(DateTime(2021, 1, 1, 2, 15)), tg,  1) ==
                  findnext(f(DateTime(2021, 1, 1, 2, 15)), vg,  1)

            @test findnext(f(DateTime(2021, 1, 1, 0, 33)), tg,  3) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 33)), vg,  3)
            @test findnext(f(DateTime(2021, 1, 1, 0, 30)), tg,  3) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 30)), vg,  3)
            @test findnext(f(DateTime(2021, 1, 1, 0, 29)), tg,  3) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 29)), vg,  3)

            @test findnext(f(DateTime(2021, 1, 1, 0, 33)), tg,  2) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 33)), vg,  2)
            @test findnext(f(DateTime(2021, 1, 1, 0, 30)), tg,  2) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 30)), vg,  2)
            @test findnext(f(DateTime(2021, 1, 1, 0, 29)), tg,  2) ==
                  findnext(f(DateTime(2021, 1, 1, 0, 29)), vg,  2)

            @test findnext(f(Date(2019, 1, 1)), tg,  2) ==
                  findnext(f(Date(2019, 1, 1)), vg,  2)
            @test findnext(f(Date(2019, 1, 1)), tg,  2) ==
                  findnext(f(Date(2019, 1, 1)), vg,  2)
            @test findnext(f(Date(2019, 1, 1)), tg,  2) ==
                  findnext(f(Date(2019, 1, 1)), vg,  2)

            @test_throws BoundsError findnext(f(DateTime(2021, 1, 1, 0, 33)), tg, 0)
            @test_throws BoundsError findnext(f(DateTime(2021, 1, 1, 0, 33)), tg, -1)
            if Base.haslength(tg)
                @test findnext(f(DateTime(2021, 1, 1, 0, 33)), tg, 42) |> isnothing
            end
        end

        # NearestNeighbors
        @info "findnext :: $(typeof(tg)) :: f -> nns :: d -> :both"

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(15), direction = :both)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(2), direction = :both)
        @test findnext(nn, tg, 1) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(3), direction = :both)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 42), radius = Minute(33), direction = :both)
        @test findnext(nn, tg, 1) == 4
        @test findnext(nn, tg, 5) == 5
        @test findnext(nn, tg, 6) == 6
        @test findnext(nn, tg, 7) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 22, 30), radius = Minute(15), direction = :both)
        @test findnext(nn, tg, 1)  == 2
        @test findnext(nn, tg, 2)  == 2
        @test findnext(nn, tg, 3)  == 3
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :both)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :both)
        @test findnext(nn, tg, 1) == 1
        @test findnext(nn, tg, 2) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :both)
        @test findnext(nn, tg, 1) == 1
        @test findnext(nn, tg, 2) == nothing

        if Base.haslength(tg)
            nn = nns(c = DateTime(2021, 1, 1, 2, 27), radius = Minute(15), direction = :both)
            @test findnext(nn, tg, 1)  == 10
            @test findnext(nn, tg, 10) == 10

            nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :both)
            @test findnext(nn, tg, 1)  == 10
            @test findnext(nn, tg, 10) == 10
        end

        @info "findnext :: $(typeof(tg)) :: f -> nns :: d -> :forward"

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(15), direction = :forward)
        @test findnext(nn, tg, 1)  == 4
        @test findnext(nn, tg, 4)  == 4
        @test findnext(nn, tg, 5)  == nothing
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(3), direction = :forward)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 42), radius = Minute(33), direction = :forward)
        @test findnext(nn, tg, 1) == 4
        @test findnext(nn, tg, 5) == 5
        @test findnext(nn, tg, 6) == 6
        @test findnext(nn, tg, 7) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 22, 30), radius = Minute(15), direction = :forward)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing
        @test findnext(nn, tg, 5) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :forward)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :forward)
        @test findnext(nn, tg, 1) == 1
        @test findnext(nn, tg, 2) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :forward)
        @test findnext(nn, tg, 1) == 1
        @test findnext(nn, tg, 2) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 2, 12), radius = Minute(15), direction = :forward)
        @test findnext(nn, tg, 1) == 10

        if Base.haslength(tg)
            nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :forward)
            @test findnext(nn, tg, 1) == nothing
        end

        @info "findnext :: $(typeof(tg)) :: f -> nns :: d -> :backward"

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1) == 3
        @test findnext(nn, tg, 2) == 3
        @test findnext(nn, tg, 3) == 3
        @test findnext(nn, tg, 4) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 33), radius = Minute(3), direction = :backward)
        @test findnext(nn, tg, 1)  == 3
        @test findnext(nn, tg, 3)  == 3
        @test findnext(nn, tg, 4)  == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 27), radius = Minute(3), direction = :backward)
        @test findnext(nn, tg, 3)  == nothing
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 48), radius = Minute(33), direction = :backward)
        @test findnext(nn, tg, 1) == 4
        @test findnext(nn, tg, 4) == 4
        @test findnext(nn, tg, 5) == nothing
        @test findnext(nn, tg, 6) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 0, 30), radius = Minute(0), direction = :backward)
        @test findnext(nn, tg, 2)  == 3
        @test findnext(nn, tg, 3)  == 3
        @test findnext(nn, tg, 4)  == nothing
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 48), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1)  == nothing
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2020, 12, 31, 23, 45), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1)  == nothing
        @test findnext(nn, tg, 10) == nothing

        nn = nns(c = DateTime(2021, 1, 1, 2, 30), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1)  == 10 + 1 * !Base.haslength(tg)
        @test findnext(nn, tg, 10) == 10 + 1 * !Base.haslength(tg)

        nn = nns(c = DateTime(2021, 1, 1, 2, 27), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1)  == 10
        @test findnext(nn, tg, 10) == 10

        nn = nns(c = DateTime(2021, 1, 1, 2, 33), radius = Minute(15), direction = :backward)
        @test findnext(nn, tg, 1)  == ifelse(Base.haslength(tg), nothing, 11)
        @test findnext(nn, tg, 10) == ifelse(Base.haslength(tg), nothing, 11)
    end

    @testset "findnext finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        vg = collect(tg)
        test_findnext(tg, vg)
    end

    @testset "findnext infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        vg = collect(Iterators.take(tg, 20))
        test_findnext(tg, vg)
    end

    function test_findfirst(tg::TimeGrid, vg)
        for f ∈ [≤, <, ≥, >, ==, isequal]
            @info "findfirst :: $(typeof(tg)) :: f -> $f"

            @test findfirst(f(DateTime(2021, 1, 1, 0, 33)), tg) ==
                  findfirst(f(DateTime(2021, 1, 1, 0, 33)), vg)
            @test findfirst(f(DateTime(2021, 1, 1, 0, 30)), tg) ==
                  findfirst(f(DateTime(2021, 1, 1, 0, 30)), vg)
            @test findfirst(f(DateTime(2021, 1, 1, 0, 29)), tg) ==
                  findfirst(f(DateTime(2021, 1, 1, 0, 29)), vg)
            @test findfirst(f(DateTime(2021, 1, 1)),        tg) ==
                  findfirst(f(DateTime(2021, 1, 1)),        vg)
            @test findfirst(f(DateTime(2021, 1, 1, 2, 15)), tg) ==
                  findfirst(f(DateTime(2021, 1, 1, 2, 15)), vg)
            @test findfirst(f(Date(2019, 1, 1)), tg) ==
                  findfirst(f(Date(2019, 1, 1)), vg)
        end
    end

    @testset "findfirst finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        vg = collect(tg)
        test_findfirst(tg, vg)
    end

    @testset "findfirst infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        vg = collect(Iterators.take(tg, 20))
        test_findfirst(tg, vg)
    end

    function test_findlast(tg::TimeGrid, vg)
        for f ∈ [≤, <, ≥, >, ==, isequal]
            @info "findlast :: $(typeof(tg)) :: f -> $f"

            if !Base.haslength(tg) && f ∈ [≥, >]
                @test_throws DomainError findlast(f(DateTime(2021, 1, 1)), tg)
                continue
            end

            @test findlast(f(DateTime(2021, 1, 1, 0, 33)), tg) ==
                  findlast(f(DateTime(2021, 1, 1, 0, 33)), vg)
            @test findlast(f(DateTime(2021, 1, 1, 0, 30)), tg) ==
                  findlast(f(DateTime(2021, 1, 1, 0, 30)), vg)
            @test findlast(f(DateTime(2021, 1, 1, 0, 29)), tg) ==
                  findlast(f(DateTime(2021, 1, 1, 0, 29)), vg)
            @test findlast(f(DateTime(2021, 1, 1)),        tg) ==
                  findlast(f(DateTime(2021, 1, 1)),        vg)
            @test findlast(f(DateTime(2021, 1, 1, 2, 15)), tg) ==
                  findlast(f(DateTime(2021, 1, 1, 2, 15)), vg)
            @test findlast(f(Date(2019, 1, 1)), tg) ==
                  findlast(f(Date(2019, 1, 1)), vg)
        end
    end

    @testset "findlast finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        vg = collect(tg)
        test_findlast(tg, vg)
    end

    @testset "findlast infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        vg = collect(Iterators.take(tg, 20))
        test_findlast(tg, vg)
    end

    function test_findall(tg, vg)
        for f ∈ [≤, <, ≥, >, ==, isequal]
            @info "findall :: $(typeof(tg)) :: f -> $f"

            if !Base.haslength(tg) && f ∈ [≥, >]
                @test_throws DomainError findlast(f(DateTime(2021, 1, 1)), tg)
                continue
            end

            @test findall(f(DateTime(2021, 1, 1, 0, 33)), tg) ==
                  findall(f(DateTime(2021, 1, 1, 0, 33)), vg)
            @test findall(f(DateTime(2021, 1, 1, 0, 30)), tg) ==
                  findall(f(DateTime(2021, 1, 1, 0, 30)), vg)
            @test findall(f(DateTime(2021, 1, 1, 0, 29)), tg) ==
                  findall(f(DateTime(2021, 1, 1, 0, 29)), vg)
            @test findall(f(DateTime(2021, 1, 1)),        tg) ==
                  findall(f(DateTime(2021, 1, 1)),        vg)
            @test findall(f(DateTime(2021, 1, 1, 2, 15)), tg) ==
                  findall(f(DateTime(2021, 1, 1, 2, 15)), vg)
            @test findall(f(Date(2019, 1, 1)), tg) ==
                  findall(f(Date(2019, 1, 1)), vg)
        end
    end

    @testset "findall finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        vg = collect(Iterators.take(tg, 20))
        test_findall(tg, vg)
    end

    @testset "findall infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        vg = collect(Iterators.take(tg, 20))
        test_findall(tg, vg)
    end

    @testset "findall with two timegrids" begin
        tg  = TimeGrid(DateTime(2021, 1, 1),        Minute(15), 10)
        tg′ = TimeGrid(DateTime(2021, 1, 1, 0, 33), Minute(12))
        @info "findall :: $(typeof(tg)) :: $(typeof(tg′)))"

        A = findall(tg, tg′)
        @test length(A) == 10

        B = [missing, missing, missing, 2, missing, missing, missing, 7, missing, missing]
        @test isequal(A, B)
    end
end  # @testset "find*"


@testset "count" begin
    function test_count(tg::TimeGrid)
        @info "count :: $(typeof(tg))"

        @test count(DateTime(2020, 1, 1)..DateTime(2020, 2, 1), tg) == 0
        @test count(DateTime(2020, 1, 1)..DateTime(2021, 1, 1), tg) == 1
        @test count(DateTime(2020, 1, 1)..DateTime(2021, 1, 1, 2, 15), tg) == 10
    end

    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        test_count(tg)
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        test_count(tg)
    end
end  # @testset "count"


@testset "reduce" begin
    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "reduce :: $(typeof(tg))"

        @test reduce(max, tg) == tg[end]
        @test reduce(max, tg, init = DateTime(2077, 1, 1)) == DateTime(2077, 1, 1)
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "reduce :: $(typeof(tg))"

        @test_throws BoundsError reduce(max, tg)
    end
end


@testset "foldl" begin
    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "foldl :: $(typeof(tg))"

        @test foldl(max, tg) == tg[end]
        @test foldl(max, tg, init = DateTime(2077, 1, 1)) == DateTime(2077, 1, 1)
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "foldl :: $(typeof(tg))"

        @test_throws BoundsError foldl(max, tg)
    end
end


@testset "foldr" begin
    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "foldr :: $(typeof(tg))"

        @test foldr(max, tg) == tg[end]
        @test foldr(max, tg, init = DateTime(2077, 1, 1)) == DateTime(2077, 1, 1)
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "foldr :: $(typeof(tg))"

        @test_throws BoundsError foldr(max, tg)
    end
end


@testset "view" begin
    @testset "finite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15), 10)
        @info "view :: $(typeof(tg))"

        @test view(tg, 2:9)[1]    == DateTime(2021, 1, 1, 0, 15)
        @test view(tg, 2:9)[end]  == DateTime(2021, 1, 1, 2, 0)
        @test view(tg, 2..9)[1]   == DateTime(2021, 1, 1, 0, 15)
        @test view(tg, 2..9)[end] == DateTime(2021, 1, 1, 2, 0)
        @test view(tg, 2:2:10).p  == Minute(30)
    end

    @testset "infinite" begin
        tg = TimeGrid(DateTime(2021, 1, 1), Minute(15))
        @info "view :: $(typeof(tg))"

        @test view(tg, 2:9)[1]    == DateTime(2021, 1, 1, 0, 15)
        @test view(tg, 2:9)[end]  == DateTime(2021, 1, 1, 2, 0)
        @test view(tg, 2..9)[1]   == DateTime(2021, 1, 1, 0, 15)
        @test view(tg, 2..9)[end] == DateTime(2021, 1, 1, 2, 0)
        @test view(tg, 2:2:10).p  == Minute(30)
    end
end


end  # @testset "TimeGrid"
