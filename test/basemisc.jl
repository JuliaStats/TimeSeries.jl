using Base.Test

using MarketData

using TimeSeries


@testset "basemisc" begin


@testset "cumulative functions" begin
    let ta = cumsum(cl)
        @test ta.values == cumsum(cl.values)
        @test ta.meta == cl.meta
    end

    let ta = cumsum(ohlc)
        @test ta.values == cumsum(ohlc.values)
        @test ta.meta == ohlc.meta
    end

    let ta = cumsum(cl, 2)
        @test ta.values == cumsum(cl.values, 2)
        @test ta.meta == cl.meta
    end

    let ta = cumsum(ohlc, 2)
        @test ta.values == cumsum(ohlc.values, 2)
        @test ta.meta == ohlc.meta
    end

    @test_throws DimensionMismatch cumsum(cl, 3)
    @test_throws DimensionMismatch cumsum(ohlc, 3)

    let ta = cumprod(cl[1:5])
        @test ta.values == cumprod(cl[1:5].values)
        @test ta.meta == cl[1:5].meta
    end

    let ta = cumprod(ohlc[1:5])
        @test ta.values == cumprod(ohlc[1:5].values)
        @test ta.meta == ohlc[1:5].meta
    end

    let ta = cumprod(cl[1:5], 2)
        @test ta.values == cumprod(cl[1:5].values, 2)
        @test ta.meta == cl[1:5].meta
    end

    let ta = cumprod(ohlc[1:5], 2)
        @test ta.values == cumprod(ohlc[1:5].values, 2)
        @test ta.meta == ohlc[1:5].meta
    end

    @test_throws DimensionMismatch cumprod(cl, 3)
    @test_throws DimensionMismatch cumprod(ohlc, 3)
end

@testset "reduction functions" begin
    for (fname, f) ∈ ([(:sum, sum), (:mean, mean)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test ta.meta == src.meta
                    @test length(ta) == 1
                    @test ta.values == f(src.values, 1)
                end

                let ta = f(src, 2)
                    @test ta.meta == src.meta
                    @test length(ta) == length(src.timestamp)
                    @test ta.values == f(src.values, 2)
                    @test ta.colnames == [string(fname)]
                end

                @test_throws DimensionMismatch f(src, 3)
            end  # @testset
        end
    end  # for func

    for (fname, f) ∈ ([(:std, std), (:var, var)])
        for (name, src) ∈ [(:cl, cl), (:ohlc, ohlc)]
            @testset "$fname::$name" begin
                let ta = f(src)
                    @test ta.meta == src.meta
                    @test length(ta) == 1
                    @test ta.values == f(src.values, 1)
                end

                let ta = f(src, 2, corrected=false)
                    @test ta.meta == src.meta
                    @test length(ta) == length(src.timestamp)
                    @test ta.values == f(src.values, 2, corrected=false)
                    @test ta.colnames == [string(fname)]
                end

                @test_throws DimensionMismatch f(src, 3)
            end  # @testset
        end
    end  # for func
end


@testset "Base.any function" begin
  let  # single column
    """
    julia> any(x .== lag(x))
    1x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-07 to 2000-01-07
    │            │ _     │
    ├────────────┼───────┤
    │ 2000-01-07 │ false │
    """
    let
      ts = cl.timestamp[1:5]
      ta = TimeArray(ts, 1:5)
      xs = any(ta .== lag(ta))
      @test xs.timestamp[] == ts[end]
      @test xs.values[]    == false
    end

    """
    julia> any(x .== lag(x), 2)
    4x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-04 to 2000-01-07
    │            │ any   │
    ├────────────┼───────┤
    │ 2000-01-04 │ false │
    │ 2000-01-05 │ true  │
    │ 2000-01-06 │ false │
    │ 2000-01-07 │ false │
    """
    let
      ts = cl.timestamp[1:5]
      ta = TimeArray(ts, [1, 2, 2, 3, 4])
      xs = any(ta .== lag(ta), 2)

      @test xs.timestamp == ts[2:end]
      @test any(xs.values .== [false, true, false, false])
      @test xs.colnames == ["any"]
    end
  end  # single column

  let  # multi column
    """
    julia> x .> 3
    3x2 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
    │            │ A     │ B     │
    ├────────────┼───────┼───────┤
    │ 2000-01-03 │ false │ false │
    │ 2000-01-04 │ false │ true  │
    │ 2000-01-05 │ true  │ true  │

    julia> any(x .> 3, 2)
    3x1 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
    │            │ any   │
    ├────────────┼───────┤
    │ 2000-01-03 │ false │
    │ 2000-01-04 │ true  │
    │ 2000-01-05 │ true  │
    """
    ts = cl.timestamp[1:3]
    ta = TimeArray(ts, [1 2; 3 4; 5 6])
    xs = any(ta .> 3, 2)

    @test xs.timestamp == ts
    @test any(xs.values .== [false, true, true])
    @test xs.colnames == ["any"]
  end  # multi column
end  # @testset "Base.any" function


@testset "Base.all function" begin
  let  # single column
    """
    julia> all(x .== lag(x))
    1x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-07 to 2000-01-07
    │            │ _     │
    ├────────────┼───────┤
    │ 2000-01-07 │ false │
    """
    let
      ts = cl.timestamp[1:5]
      ta = TimeArray(ts, 1:5)
      xs = all(ta .== lag(ta))
      @test xs.timestamp[] == ts[end]
      @test xs.values[]    == false
    end

    """
    julia> all(x .== lag(x), 2)
    4x1 TimeSeries.TimeArray{Bool,1,Date,BitArray{1}} 2000-01-04 to 2000-01-07
    │            │ any   │
    ├────────────┼───────┤
    │ 2000-01-04 │ false │
    │ 2000-01-05 │ true  │
    │ 2000-01-06 │ false │
    │ 2000-01-07 │ false │
    """
    let
      ts = cl.timestamp[1:5]
      ta = TimeArray(ts, [1, 2, 2, 3, 4])
      xs = all(ta .== lag(ta), 2)

      @test xs.timestamp == ts[2:end]
      @test all(xs.values .== [false, true, false, false])
      @test xs.colnames == ["all"]
    end
  end  # single column

  let  # multi column
    """
    julia> x .> 3
    3x2 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
    │            │ A     │ B     │
    ├────────────┼───────┼───────┤
    │ 2000-01-03 │ false │ false │
    │ 2000-01-04 │ false │ true  │
    │ 2000-01-05 │ true  │ true  │

    julia> all(x .> 3, 2)
    3x1 TimeSeries.TimeArray{Bool,2,Date,BitArray{2}} 2000-01-03 to 2000-01-05
    │            │ all   │
    ├────────────┼───────┤
    │ 2000-01-03 │ false │
    │ 2000-01-04 │ false │
    │ 2000-01-05 │ true  │
    """
    ts = cl.timestamp[1:3]
    ta = TimeArray(ts, [1 2; 3 4; 5 6])
    xs = all(ta .> 3, 2)

    @test xs.timestamp == ts
    @test all(xs.values .== [false, false, true])
    @test xs.colnames == ["all"]
  end  # multi column
end  # @testset "Base.all" function


end  # @testset "basemisc"
