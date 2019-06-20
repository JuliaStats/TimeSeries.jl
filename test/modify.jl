using Dates
using Test

using MarketData

using TimeSeries


@testset "modify" begin


@testset "update method works" begin
    new_cls  = update(cl, today(), 111.11)
    new_clv  = update(cl, today(), [111.11])
    new_ohlc = update(ohlc, today(), [111.11 222.22 333.33 444.44])
    empty1   = TimeArray(Vector{Date}(), Array{Int}(undef, 0,1))
    empty2   = TimeArray(Vector{Date}(), Array{Int}(undef, 0,2))

    @testset "empty time arrays can be constructed" begin
        @test length(empty1) == 0
        @test length(empty2) == 0
    end

    @testset "update an empty time array fails" begin
        @test_throws ArgumentError update(empty1, Date(2000,1,1), 10)
        @test_throws ArgumentError update(empty2, Date(2000,1,1), [10 11])
    end

    @testset "update a single column time array with single value vector" begin
        @test last(values(new_clv)) == 111.11
        @test_throws DimensionMismatch update(cl, today(), [111.11, 222.22])
    end

    @testset "update a multi column time array" begin
        @test values(tail(new_ohlc, 1)) == [111.11 222.22 333.33 444.44]
        @test_throws MethodError update(ohlc, today(), [111.11, 222.22, 333.33])
    end

    @testset "cannot update more than one observation at a time" begin
        @test_throws(
            MethodError,
            update(cl, [Date(2002,1,1), Date(2002,1,2)], [111.11, 222,22]))
    end

    @testset "cannot update oldest observations" begin
        @test_throws ArgumentError update(cl, Date(1999,1,1), [111.11])
        @test_throws ArgumentError update(cl, Date(1999,1,1), 111.11)
    end

    @testset "cannot update in-between observations" begin
        @test_throws ArgumentError update(cl, Date(2000,1,8), [111.11])
        @test_throws ArgumentError update(cl, Date(2000,1,8), 111.11)
    end
end


@testset "rename method works" begin
    re_ohlc = rename(ohlc, [:a, :b, :c, :d])
    re_cl   = rename(cl, [:vector])
    re_cls  = rename(cl, :symbol)

    @testset "change colnames with multi-member vector" begin
        @test colnames(re_ohlc) == [:a, :b, :c, :d]
        @test_throws ArgumentError rename(ohlc, [:a])
    end

    @testset "change colnames with single-member vector" begin
        @test colnames(re_cl) == [:vector]
        @test_throws ArgumentError rename(cl, [:a, :b])
    end

    @testset "change colnames with pair" begin
        re_ohlc_2 = rename(ohlc, :Open => :a)
        @test colnames(re_ohlc_2) == [:a, :High, :Low, :Close]
        @test_throws ArgumentError rename(ohlc, :Unknown => :A)
    end

    @testset "change colnames with several pairs" begin
        re_ohlc_2 = rename(ohlc, :Open => :a, :Close => :d)
        @test colnames(re_ohlc_2) == [:a, :High, :Low, :d]
        @test_throws MethodError rename(ohlc)
    end

    @testset "change colnames with dict" begin
        re_ohlc_2 = rename(ohlc, Dict(:Open => :a, :Close => :d)...)
        @test colnames(re_ohlc_2) == [:a, :High, :Low, :d]
    end

    @testset "change colnames with function" begin
        @testset "lambda function" begin
            f = colname -> Symbol(uppercase(string(colname)))
            re_ohlc_2 = rename(f, ohlc)
            @test colnames(re_ohlc_2) == [:OPEN, :HIGH, :LOW, :CLOSE]
        end

        @testset "function composition" begin
            f = Symbol ∘ uppercase ∘ string
            re_ohlc_2 = rename(f, ohlc)
            @test colnames(re_ohlc_2) == [:OPEN, :HIGH, :LOW, :CLOSE]
        end

        @testset "do block" begin
            re_ohlc_2 = rename(ohlc) do x
                x |> string |> uppercase |> Symbol
            end
            @test colnames(re_ohlc_2) == [:OPEN, :HIGH, :LOW, :CLOSE]
        end

        @testset "automatic string/symbol" begin
            re_ohlc_2 = rename(uppercase, ohlc, String)
            @test colnames(re_ohlc_2) == [:OPEN, :HIGH, :LOW, :CLOSE]
        end

    end
end


@testset "rename!" begin
    let
        ta    = first(ohlc)
        cols  = [:Open, :High, :Low, :Close]
        cols′ = [:A, :B, :C, :D]
        rename!(ta, [:A, :B, :C, :D])
        @test colnames(ohlc) == cols
        @test colnames(ta)   == cols′
    end

    let
        ta = first(cl)
        rename!(ta, [:A])
        @test colnames(cl) == [:Close]
        @test colnames(ta) == [:A]
    end

    let
        ta = first(cl)
        rename!(ta, :A)
        @test colnames(cl) == [:Close]
        @test colnames(ta) == [:A]
    end

    let
        ta    = first(ohlc)
        cols  = [:Open,  :High, :Low,  :Close]
        cols′ = [:Open′, :High, :Low′, :Close]
        rename!(ta, :Open => :Open′, :Low => :Low′)
        @test colnames(ohlc) == cols
        @test colnames(ta)   == cols′
        @test_throws MethodError rename!(ta)
        @test_throws ArgumentError rename!(ohlc, :Unknown => :A)
    end

    let
        ta    = first(ohlc)
        cols  = [:Open, :High, :Low, :Close]
        cols′ = [:open, :high, :low, :close]
        rename!(Symbol ∘ lowercase ∘ string, ta)
        @test colnames(ohlc)  == cols
        @test colnames(ta)    == cols′
    end

    let
        ta    = first(ohlc)
        cols  = [:Open, :High, :Low, :Close]
        cols′ = [:open, :high, :low, :close]
        rename!(lowercase, ta, String)
        @test colnames(ohlc)  == cols
        @test colnames(ta)    == cols′
    end
end


end  # @testset "modify"
