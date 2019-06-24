using Dates
using Statistics
using Test

using MarketData

using TimeSeries


@testset "apply" begin


@testset "time series methods" begin
    @testset "lag takes previous day and timestamps it to next day" begin
        ta = lag(cl)
        @test values(ta)[1] ≈ 111.94 atol=.01
        @test timestamp(ta)[1] == Date(2000, 1, 4)
    end

    @testset "lag accepts other offset values" begin
        ta = lag(cl, 9)
        @test timestamp(ta)[1] == Date(2000, 1, 14)
    end

    @testset "lag operates on 2d arrays" begin
        ta = lag(ohlc, 9)
        @test timestamp(ta)[1] == Date(2000, 1, 14)
    end

    @testset "lag returns 1d from 1d time arrays" begin
        @test ndims(values(lag(cl))) == 1
    end

    @testset "lag returns 2d from 2d time arrays" begin
        @test ndims(values(lag(ohlc))) == 2
    end

    @testset "lead takes next day and timestamps it to current day" begin
        ta = lead(cl)
        @test values(ta)[1] ≈ 102.5 atol=.1
        @test timestamp(ta)[1] == Date(2000,1,3)
    end

    @testset "lead accepts other offset values" begin
        ta = lead(cl, 9)
        @test values(ta)[1] ≈ 100.44 atol=.1
        @test timestamp(ta)[1] == Date(2000,1,3)
    end

    @testset "lead operates on 2d arrays" begin
        @test timestamp(lead(ohlc, 9))[1] == Date(2000,1,3)
    end

    @testset "lead returns 1d from 1d time arrays" begin
        @test ndims(values(lead(cl))) == 1
    end

    @testset "lead returns 2d from 2d time arrays" begin
        @test ndims(values(lead(ohlc))) == 2
    end

    @testset "diff calculates 1st-order differences" begin
        @test timestamp(diff(op))                 == timestamp(diff(op, padding=false))
        @test values(diff(op))                    == values(diff(op, padding=false))
        @test values(diff(op, padding=false))[1]  == values(op[2])[1] .- values(op[1])[1]
        @test values(diff(op, padding=true))[1]    ≡ NaN
        @test values(diff(op, padding=true))[2]   == values(diff(op))[1]
        @test values(diff(op, padding=true))[2]   == values(op[2])[1] .- values(op[1])[1]
    end

    @testset "diff calculates 1st-order differences for multi-column ts" begin
        @test timestamp(diff(ohlc))                   == timestamp(diff(ohlc, padding=false))
        @test values(diff(ohlc))                      == values(diff(ohlc, padding=false))
        @test values(diff(ohlc, padding=false))[1,:]  == values(ohlc)[2, :] .- values(ohlc)[1, :]
        @test values(diff(ohlc, padding=true))[2,:]   == values(diff(ohlc))[1, :]
        @test values(diff(ohlc, padding=true))[2,:]   == values(ohlc)[2, :] .- values(ohlc)[1, :]
        @test all(x -> isnan(x), values(diff(ohlc, padding=true))[1, :])
    end

    @testset "diff calculates 2nd-order differences" begin
        @test timestamp(diff(op, differences=2))                  == timestamp(diff(op, padding=false, differences=2))
        @test timestamp(diff(diff(op)))                           == timestamp(diff(op, padding=false, differences=2))

        @test values(diff(op, differences=2))                     == values(diff(op, padding=false, differences=2))
        @test values(diff(diff(op)))                              == values(diff(op, padding=false, differences=2))

        @test values(diff(op, padding=true, differences=2))[3]    == values(diff(op, differences=2))[1]
        @test values(diff(op, padding=true, differences=2)[2])[1]  ≡ NaN
        @test values(diff(op, padding=true, differences=2)[1])[1]  ≡ NaN
    end

    @testset "diff calculates 2nd-order differences for multi-column ts" begin
        @test timestamp(diff(ohlc, differences=2))                  == timestamp(diff(ohlc, padding=false, differences=2))
        @test timestamp(diff(diff(ohlc)))                           == timestamp(diff(ohlc, padding=false, differences=2))

        @test values(diff(ohlc, differences=2))                     == values(diff(ohlc, padding=false, differences=2))
        @test values(diff(diff(ohlc)))                              == values(diff(ohlc, padding=false, differences=2))
        @test values(diff(ohlc, padding=true, differences=2))[3, :] == values(diff(ohlc, differences=2))[1, :]

        @test all(x -> isnan(x), values(diff(ohlc, padding=true, differences=2))[2,:])
        @test all(x -> isnan(x), values(diff(ohlc, padding=true, differences=2))[1,:])
    end

    @testset "diff calculates 3rd-order differences" begin
        @test diff(op, differences=3) |> timestamp               == diff(op, padding=false, differences=3) |> timestamp
        @test diff(op, differences=3) |> values                  == diff(op, padding=false, differences=3) |> values
        @test diff(diff(diff(op))) |> timestamp                  == diff(op, padding=false, differences=3) |> timestamp
        @test diff(diff(diff(op))) |> values                     == diff(op, padding=false, differences=3) |> values
        @test values(diff(op, padding=true, differences=3))[4]   == values(diff(op, differences=3))[1]
        @test values(diff(op, padding=true, differences=3))[3]    ≡ NaN
        @test values(diff(op, padding=true, differences=3))[2]    ≡ NaN
        @test values(diff(op, padding=true, differences=3))[1]    ≡ NaN
    end

    @testset "diff calculates 3rd-order differences for multi-column ts" begin
        @test diff(ohlc, differences=3) |> timestamp                 == diff(ohlc, padding=false, differences=3) |> timestamp
        @test diff(ohlc, differences=3) |> values                    == diff(ohlc, padding=false, differences=3) |> values
        @test diff(diff(diff(ohlc))) |> timestamp                    == diff(ohlc, padding=false, differences=3) |> timestamp
        @test diff(diff(diff(ohlc))) |> values                       == diff(ohlc, padding=false, differences=3) |> values
        @test values(diff(ohlc, padding=true, differences=3))[4, :]  == values(diff(ohlc, differences=3))[1, :]
        @test all(x -> isnan(x), values(diff(ohlc, padding=true, differences=3))[3,:])
        @test all(x -> isnan(x), values(diff(ohlc, padding=true, differences=3))[2,:])
        @test all(x -> isnan(x), values(diff(ohlc, padding=true, differences=3))[1,:])
    end

    @testset "diff n lag" begin
        let ta = diff(cl, 5)
            ans = cl .- lag(cl, 5)

            @test values(ta)    == values(ans)
            @test timestamp(ta) == timestamp(ans)
        end

        let ta = diff(ohlc, 5)
            ans = ohlc .- lag(ohlc, 5)

            @test values(ta)    == values(ans)
            @test timestamp(ta) == timestamp(ans)
        end
    end  # @testset "diff n lag"

    @testset "simple return value" begin
        @test values(percentchange(cl, :simple)) == values(percentchange(cl))
        @test values(percentchange(cl))          == values(percentchange(cl, padding=false))
        @test values(percentchange(cl))[1]        ≈ (102.5 - 111.94) / 111.94 atol=.01
        @test values(percentchange(ohlc))[1, :]   ≈ (values(ohlc)[2, :] - values(ohlc)[1, :]) ./ values(ohlc)[1, :]
        @test isnan.(values(percentchange(cl, padding=true))[1])
        @test values(percentchange(cl, padding=true))[2]      ≈ (102.5 - 111.94) / 111.94 atol=.01
        @test values(percentchange(ohlc, padding=true))[2, :] ≈ (values(ohlc)[2,:] - values(ohlc)[1,:]) ./ values(ohlc)[1,:]
    end

    @testset "log return value" begin
        @test values(percentchange(cl, :log)) == values(percentchange(cl, :log, padding=false))
        @test values(percentchange(cl, :log))[1]       ≈ log(102.5) - log(111.94) atol=.01
        @test values(percentchange(ohlc, :log))[1, :]  ≈ log.(values(ohlc)[2,:]) .- log.(values(ohlc)[1,:]) atol=.01
        @test isnan.(values(percentchange(cl, :log, padding=true))[1])
        @test values(percentchange(cl, :log, padding=true))[2]      ≈ log(102.5) - log(111.94)
        @test values(percentchange(ohlc, :log, padding=true))[2, :] ≈ log.(values(ohlc)[2,:]) .- log.(values(ohlc)[1,:])
    end

    @testset "moving supplies correct window length" begin
        let
            ta = moving(mean, cl, 10)
            @test values(ta)       == values(moving(mean, cl, 10, padding=false))
            @test timestamp(ta)[1] == Date(2000, 1, 14)
            @test values(ta)[1]     ≈ mean(values(cl)[1:10])
        end
        let
            ta = moving(mean, cl, 10, padding = true)
            @test timestamp(ta)   == timestamp(cl)
            @test values(ta)[1]   ≡ NaN
            @test values(ta)[10] == values(moving(mean, cl, 10))[1]
        end

        let
            ta = moving(mean, ohlc, 10)
            @test values(ta)        == values(moving(mean, ohlc, 10, padding=false))
            @test values(ta)[1, :]'  ≈ mean(values(ohlc)[1:10, :], dims = 1)
        end
        let
            ta = moving(mean, ohlc, 10, padding = true)
            @test all(isnan, values(ta)[1, :])
            @test values(ta)[10, :] == values(moving(mean, ohlc, 10))[1, :]
        end

        @testset "moving with do syntax" begin
            moving(cl, 10) do x
                @test isa(x, AbstractArray{Float64,1})
                x[1]
            end

            moving(ohlc, 10) do x
                @test isa(x, AbstractArray{Float64,1})
                x[1]
            end
        end

        @testset "moving with multi-column" begin
            ta = moving(mean, ohlc, 1, dims = 2, colnames = [:mean])
            ans = mean(ohlc, dims = 2)
            @test all(values(ta) .== values(ans))
            @test timestamp(ta)   == timestamp(ta)

            ta = moving(ohlc, 10, dims = 2) do A
                mean(A, dims = 1)
            end
            ans = moving(mean, ohlc, 10)
            @test values(ta)       ≈ values(ans)
            @test timestamp(ta)   == timestamp(ta)

            # with padding
            ta = moving(ohlc, 10, dims = 2, padding = true) do A
                mean(A, dims = 1)
            end
            @test length(ta) == length(ohlc)
            @test all(isnan.(values(ta[1:9])))

            # exceptions
            @test_throws ArgumentError moving(mean, ohlc, 24, dims = 42)
            @test_throws DimensionMismatch moving(mean, ohlc, 24, dims = 2)
        end
    end

    @testset "upto method accumulates" begin
        @test values(upto(sum, cl))[10]  ≈ sum(values(cl)[1:10])
        @test values(upto(mean, cl))[10] ≈ mean(values(cl)[1:10])

        @test timestamp(upto(sum, cl))[10]  == Date(2000, 1, 14)
        @test timestamp(upto(mean, cl))[10] == Date(2000, 1, 14)

        # transpose the upto value output from column to row vector but values are identical
        @test values(upto(sum, ohlc))[10, :]'  ≈ sum(values(ohlc)[1:10, :], dims = 1)
        @test values(upto(mean, ohlc))[10, :]' ≈ mean(values(ohlc)[1:10, :], dims = 1)
    end
end


@testset "basecall works with Base methods" begin
    @testset "cumsum works" begin
        @test values(basecall(cl, cumsum))[2] == values(cl)[1] + values(cl)[2]
    end
end


@testset "adding/removing missing rows works" begin
    uohlc = uniformspace(ohlc[1:8])

    @testset "uniform spacing detection works" begin
        @test uniformspaced(datetime1)
        @test uniformspaced(uohlc)
        @test !uniformspaced(cl)
        @test !uniformspaced(ohlc)
    end

    @testset "forcing uniform spacing works" begin
        @test length(uohlc)    == 10
        @test values(uohlc[5]) == values(ohlc[5])
        @test all(isnan, values(uohlc[6]))
        @test all(isnan, values(uohlc[7]))
        @test values(uohlc[8]) == values(ohlc[6])
    end

    @testset "dropnan works" begin
        nohlc = TimeArray(timestamp(ohlc), copy(values(ohlc)), colnames(ohlc), meta(ohlc))
        values(nohlc)[7:12, 2] .= NaN

        @test timestamp(dropnan(uohlc))       == timestamp(dropnan(uohlc, :all))
        @test values(dropnan(uohlc))          == values(dropnan(uohlc, :all))

        @test values(dropnan(ohlc, :all))     == values(ohlc)
        @test timestamp(dropnan(nohlc, :all)) == timestamp(ohlc)
        @test timestamp(dropnan(uohlc, :all)) == timestamp(ohlc[1:8])
        @test values(dropnan(uohlc, :all))    == values(ohlc[1:8])

        @test values(dropnan(ohlc, :any))     == values(ohlc)
        @test timestamp(dropnan(nohlc, :any)) == timestamp(ohlc)[[1:6;13:end]]
        @test values(dropnan(nohlc, :any))    == values(ohlc)[[1:6;13:end], :]
        @test timestamp(dropnan(uohlc, :any)) == timestamp(ohlc[1:8])
        @test values(dropnan(uohlc, :any))    == values(ohlc[1:8])
    end
end


end  # @testset "apply"
