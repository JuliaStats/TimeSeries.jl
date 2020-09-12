using Dates
using Test

using MarketData

using TimeSeries


@testset "modify" begin


@testset "rename" begin
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
end  # @testset "rename"


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
end  # @testset "rename!"


end  # @testset "modify"
