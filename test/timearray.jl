using Dates
using Test

using MarketData

using TimeSeries


@testset "timearray" begin


@testset "field extraction methods work" begin
    @testset "timestamp, values, colnames and meta" begin
        for ta ∈ [cl, op, ohlc]
            @test timestamp(ta) isa Vector{Date}
            @test values(ta)    isa Array{Float64}
            @test colnames(ta)  isa Vector{Symbol}
            @test meta(mdata) == "Apple"
        end
    end
end


@testset "type constructors allow views" begin
    source_rows = 101:121
    source_cols = 1:size(values(AAPL), 2)
    tstamps = view(timestamp(AAPL), source_rows)
    tvalues = view(values(AAPL), source_rows, source_cols)

    AAPL1 = TimeArray(timestamp(AAPL)[source_rows],
                      values(AAPL)[source_rows, source_cols],
                      colnames(AAPL), meta(AAPL))

    AAPL2 = TimeArray(tstamps, tvalues, colnames(AAPL), meta(AAPL))

    @testset "match first date" begin
        @test timestamp(AAPL1)[1] == timestamp(AAPL2)[1]
    end

    @testset "match first values" begin
        @test values(AAPL1)[1] == values(AAPL2)[1]
    end

    @testset "match all values" begin
        @test values(AAPL1) == values(AAPL2)
    end
end


@testset "type constructors enforce invariants" begin
    mangled_stamp = vcat(timestamp(cl)[200:end], timestamp(cl)[1:199])
    dupe_stamp    = vcat(timestamp(cl)[1:499], timestamp(cl)[499])

    @testset "unequal length between values and timestamp fails" begin
        @test_throws(
            DimensionMismatch,
            TimeArray(timestamp(cl), values(cl)[2:end], [:Close]))
    end

    @testset "unequal length between colnames and array width fails" begin
        @test_throws(
            DimensionMismatch,
            TimeArray(timestamp(cl), values(cl), [:Close, :Open]))
    end

    @testset "duplicate timestamp values fails" begin
        @test_throws(
            ArgumentError,
            TimeArray(dupe_stamp, values(cl), [:Close]))
    end

    @testset "mangled order of timestamp values fails" begin
        @test_throws(
            ArgumentError,
            TimeArray(mangled_stamp, values(cl), [:Close]))
    end

    @testset "reverse occurs when needed" begin
        rev_timestamp = reverse(timestamp(cl), dims = 1)
        rev_values = reverse(values(cl), dims = 1)
        ta = TimeArray(rev_timestamp, rev_values, [:Close])
        @test timestamp(ta)[1] == Date(2000,1,3)
        @test values(ta)[1]    == 111.94
    end

    @testset "duplicate column names are enumerated by inner constructor" begin
        cols = [:a, :b, :c, :a, :a, :b, :d, :e, :e, :e, :e, :f]
        ta = TimeArray(timestamp(AAPL), values(AAPL), cols)
        @test colnames(ta)[1]  == :a
        @test colnames(ta)[2]  == :b
        @test colnames(ta)[3]  == :c
        @test colnames(ta)[4]  == :a_1
        @test colnames(ta)[5]  == :a_2
        @test colnames(ta)[6]  == :b_1
        @test colnames(ta)[7]  == :d
        @test colnames(ta)[8]  == :e
        @test colnames(ta)[9]  == :e_1
        @test colnames(ta)[10] == :e_2
        @test colnames(ta)[11] == :e_3
        @test colnames(ta)[12] == :f
    end

    @testset "and doesn't when unchecked" begin
        let
            ta = TimeArray(mangled_stamp, values(cl); unchecked = true)
            @test values(ta)    === values(cl)
            @test timestamp(ta) === mangled_stamp
        end

        let
            ta = TimeArray(dupe_stamp, values(cl); unchecked = true)
            @test timestamp(ta) === dupe_stamp
        end
    end
end

@testset "construction without colnames" begin
    one   = TimeArray(timestamp(cl), values(cl))
    multi = TimeArray(timestamp(AAPL), values(AAPL))
    more  = TimeArray(timestamp(cl)[1], collect(1:50)')

    @testset "default colnames" begin
        @test colnames(one)   == [:A]
        @test colnames(multi) == [:A, :B, :C, :D, :E, :F, :G, :H, :I, :J, :K, :L]
        @test colnames(more)  == [:A, :B, :C, :D, :E, :F, :G, :H, :I, :J, :K, :L, :M,
                                  :N, :O, :P, :Q, :R, :S, :T, :U, :V, :W, :X, :Y, :Z,
                                  :AA, :AB, :AC, :AD, :AE, :AF, :AG, :AH, :AI, :AJ, :AK,
                                  :AL, :AM, :AN, :AO, :AP, :AQ, :AR, :AS, :AT, :AU, :AV,
                                  :AW, :AX]
    end

    @testset "empty colnames forces meta to nothing" begin
        @test meta(one)   == nothing
        @test meta(multi) == nothing
        @test meta(more)  == nothing
    end
end


@testset "construct with StepRange{Date,Day}" begin
    drng = Date(2000,1,1):Day(1):Date(2000,1,5)
    ta = TimeArray(drng, 1:5)

    @test timestamp(ta)[1]   == first(drng)
    @test timestamp(ta)[end] == last(drng)

    @test values(ta)[1]   == 1
    @test values(ta)[end] == 5
end


@testset "construction from existing TimeArray" begin
    ts = Date(2018, 1, 1):Day(1):Date(2018, 1, 31)
    ta = TimeArray(ts, 1:31, [:x], :Meta)

    let
        ts′ = Date(2018, 3, 1):Day(1):Date(2018, 3, 31)
        ta′ = TimeArray(ta; timestamp = ts′)
        @test timestamp(ta′) == ts′
        @test values(ta′)    == values(ta)
        @test colnames(ta′)  == colnames(ta)
        @test meta(ta′)      == meta(ta)
    end

    let
        ta′ = TimeArray(ta; values = 2:32)
        @test timestamp(ta′) == timestamp(ta)
        @test values(ta′)    == 2:32
        @test colnames(ta′)  == colnames(ta)
        @test meta(ta′)      == meta(ta)
    end

    let
        ta′ = TimeArray(ta; colnames = [:y])
        @test timestamp(ta′) == timestamp(ta)
        @test values(ta′)    == values(ta)
        @test colnames(ta′)  == [:y]
        @test meta(ta′)      == meta(ta)
    end

    let
        ta′ = TimeArray(ta; meta = :Meta42)
        @test timestamp(ta′) == timestamp(ta)
        @test values(ta′)    == values(ta)
        @test colnames(ta′)  == colnames(ta)
        @test meta(ta′)      == :Meta42
    end
end

@testset "construct with NamedTuple" begin
    data = (datetime=[DateTime(2018, 11, 21, 12, 0), DateTime(2018, 11, 21, 13, 0)], col1=[10.2, 11.2], col2=[20.2, 21.2], col3=[30.2, 31.2])
    ta = TimeArray(data; timestamp=:datetime, meta="Example")
    @test size(ta) == (2, 3)
    @test colnames(ta) == [:col1, :col2, :col3]
    @test timestamp(ta) == [DateTime(2018, 11, 21, 12, 0), DateTime(2018, 11, 21, 13, 0)]
    @test values(ta) == [10.2 20.2 30.2; 11.2 21.2 31.2]
    @test meta(ta) == "Example"
end

@testset "conversion methods" begin
    @testset "convert works " begin
        @test convert(TimeArray{Float64,1}, (cl.>op))                isa TimeArray{Float64,1}
        @test convert(TimeArray{Float64,2}, (merge(cl.<op, cl.>op))) isa TimeArray{Float64,2}
        @test convert(cl.>op)                                        isa TimeArray{Float64,1}
        @test convert(merge(cl.<op, cl.>op))                         isa TimeArray{Float64,2}
    end
end

@testset "copy methods" begin
    cop = copy(op)
    cohlc = copy(ohlc)

    @testset "copy works" begin
        @test timestamp(cop) == timestamp(op)
        @test values(cop)    == values(op)
        @test colnames(cop)  == colnames(op)
        @test meta(cop)      == meta(op)

        @test timestamp(cohlc) == timestamp(ohlc)
        @test values(cohlc)    == values(ohlc)
        @test colnames(cohlc)  == colnames(ohlc)
        @test meta(cohlc)      == meta(ohlc)
    end
end

@testset "index by integer works with both 1d and 2d time array" begin
    @testset "1d time array" begin
        ta = cl[1]
        @test timestamp(ta) == [Date(2000,1,3)]
        @test values(ta)    == [111.94]
        @test colnames(ta)  == [:Close]
        @test meta(ta)      == "AAPL"
    end

    @testset "2d time array" begin
        ta = ohlc[1]
        @test timestamp(ta) == [Date(2000,1,3)]
        @test values(ta)    == [104.88 112.5 101.69 111.94]
        @test colnames(ta)  == [:Open, :High, :Low, :Close]
        @test meta(ta)      == "AAPL"
    end

    @test_throws BoundsError cl[]
    @test_throws BoundsError ohlc[]
end


@testset "ordered collection methods" begin
    @testset "iteration protocol is valid" begin
        let  # single column
            i = 1
            for (t, val) ∈ cl[1:3]
                @test t   == timestamp(cl)[i]
                @test val == values(cl)[i]
                i += 1
            end
        end

        let  # multiple column
            i = 1
            for (t, val) ∈ ohlc[1:3]
                @test t   == timestamp(ohlc)[i]
                @test val == values(ohlc)[i, :]
                i += 1
            end
        end
    end

    @testset "end keyword returns correct index" begin
        @test timestamp(ohlc[end])[1] == timestamp(ohlc)[end]
    end

    @testset "getindex on single Int and Date" begin
        @test timestamp(ohlc[1])              == [Date(2000,1,3)]
        @test timestamp(ohlc[Date(2000,1,3)]) == [Date(2000,1,3)]
    end

    @testset "getindex on array of Int and Date" begin
        @test timestamp(ohlc[[1,10]])                           == [Date(2000,1,3), Date(2000,1,14)]
        @test timestamp(ohlc[[Date(2000,1,3),Date(2000,1,14)]]) == [Date(2000,1,3), Date(2000,1,14)]
    end

    @testset "getindex on range of Int and Date" begin
        irng = Int8(1):Int8(2):Int8(4)
        drng = Date(2000,1,3):Day(1):Date(2000,1,4)
        @test timestamp(ohlc[1:2])   == [Date(2000,1,3), Date(2000,1,4)]
        @test timestamp(ohlc[1:2:4]) == [Date(2000,1,3), Date(2000,1,5)]
        @test timestamp(ohlc[irng])  == [Date(2000,1,3), Date(2000,1,5)]
        @test timestamp(ohlc[drng])  == [Date(2000,1,3), Date(2000,1,4)]
    end

    @testset "getindex on range of DateTime when only Date is in timestamp" begin
        @test_throws(
            MethodError,
            ohlc[DateTime(2000,1,3,0,0,0)])
        @test_throws(
            MethodError,
            ohlc[[DateTime(2000,1,3,0,0,0),DateTime(2000,1,14,0,0,0)]])
        @test_throws(
            MethodError,
            ohlc[DateTime(2000,1,3,0,0,0):Day(1):DateTime(2000,1,4,0,0,0)])
    end

    @testset "getindex on range of Date" begin
        @test length(cl[Date(2000,1,1):Day(1):Date(2001,12,31)]) == 500
    end

    @testset "getindex on single column name" begin
        idx = Date(2000,1,3):Day(1):Date(2000,1,14)
        @test size(values(ohlc[:Open]), 2)      == 1
        @test size(values(ohlc[:Open][idx]), 1) == 10
    end

    @testset "getindex on multiple column name" begin
        @test values(ohlc[:Open, :Close])[1]   == 104.88
        @test values(ohlc[:Open, :Close])[2]   == 108.25
        @test values(ohlc[:Open, :Close])[501] == 111.94
    end

    @testset "getindex on 1d returns 1d object" begin
        @test cl[1]   isa TimeArray{Float64,1}
        @test cl[1:2] isa TimeArray{Float64,1}
    end

    @testset "getindex on a 1d Boolean TimeArray returns appropriate rows" begin
        @test values(ohlc[op .> cl][2])             == values(ohlc[4])
        @test timestamp(ohlc[op[300:end] .> cl][2]) == timestamp(ohlc[303])
        # MethodError, Bool must be 1D-TimeArray
        @test_throws MethodError ohlc[merge(op .> cl, op .< cl)]
    end

    @testset "getindex on Vector{Symbol}" begin
        hl = [:High, :Low]
        ta = ohlc[hl]

        @test size(values(ta)) == (length(timestamp(ohlc)), 2)
        @test colnames(ta) == hl
    end

    @testset "2D getindex on [Vector{Int}, Vector{Symbol}]" begin
        hl = [:High, :Low]
        ta = ohlc[1:10, hl]

        @test size(values(ta)) == (10, 2)
        @test colnames(ta) == hl

        ta = ohlc[10:end, hl]
        @test size(values(ta)) == (length(timestamp(ohlc)) - 9, 2)
        @test colnames(ta) == hl

        ta = ohlc[:, hl]
        @test size(values(ta)) == (length(timestamp(ohlc)), 2)
        @test colnames(ta) == hl

        # test KeyError
        @test_throws KeyError ohlc[1:2, [:Unknown]]
        @test_throws KeyError ohlc[1:end, [:Unknown]]
        @test_throws KeyError ohlc[:, [:Unknown]]
    end

    @testset "2D getindex on [Integer, Vector{Symbol}]" begin
        hl = [:High, :Low]
        ta = ohlc[42, hl]
        @test size(values(ta)) == (1, 2)
        @test colnames(ta) == hl

        ta = ohlc[end, hl]
        @test size(values(ta)) == (1, 2)
        @test colnames(ta) == hl

        @test_throws KeyError ohlc[42, [:Unknown]]
    end

    @testset "2D getindex on [Vector{Int}, Symbol]" begin
        ta = ohlc[1:42, :Open]
        @test size(values(ta)) == (42, 1)
        @test colnames(ta) == [:Open]

        ta = ohlc[42:43, :Close]
        @test size(values(ta)) == (2, 1)
        @test colnames(ta) == [:Close]

        @test_throws KeyError ohlc[1:42, :Unknown]
    end

    @testset "2D getindex on [Integer, Symbol]" begin
        ta = ohlc[42, :Open]
        @test size(values(ta)) == (1, 1)
        @test colnames(ta) == [:Open]

        @test_throws KeyError ohlc[42, :Unknown]
    end

    @testset "Base.eachindex" begin
        @test eachindex(cl)   == 1:length(cl)
        @test eachindex(ohlc) == 1:length(ohlc)
    end
end


@testset "Base.ndims" begin
    @test ndims(cl)   == 1
    @test ndims(ohlc) == 2
end


@testset "Base.eltype" begin
    @test eltype(cl)   == Tuple{Date,Float64}
    @test eltype(ohlc) == Tuple{Date,Vector{Float64}}

    @test eltype(cl .> 1)   == Tuple{Date,Bool}
    @test eltype(ohlc .> 1) == Tuple{Date,Vector{Bool}}
end


@testset "Base.collect" begin
    @testset "cl" begin
        A = collect(cl)
        @test A[1] == (Date(2000, 01, 03), 111.94)
        @test A[2] == (Date(2000, 01, 04), 102.5)
        @test A[3] == (Date(2000, 01, 05), 104.0)
    end

    @testset "ohlc" begin
        A = collect(ohlc)
        @test A[1] == (Date(2000, 01, 03), [104.88, 112.5, 101.69, 111.94])
        @test A[2] == (Date(2000, 01, 04), [108.25, 110.62, 101.19, 102.5])
        @test A[3] == (Date(2000, 01, 05), [103.75, 110.56, 103.0, 104.0])
    end
end


@testset "Base.size" begin
    @test size(ohlc)    == (500, 4)
    @test size(ohlc, 1) == 500
    @test size(ohlc, 2) == 4

    @test size(cl)    == (500,)
    @test size(cl, 1) == 500
    @test size(cl, 2) == 1
end


@testset "equal" begin
    @test cl == copy(cl)
    @test cl ≠ ohlc  # rely on fallback definition
    @test cl ≠ lag(cl)

    @test  isequal(cl, copy(cl))
    @test !isequal(cl, ohlc)
    @test !isequal(cl, lag(cl))

    ds = DateTime(2017, 12, 25):Day(1):DateTime(2017, 12, 31) |> collect

    let  # diff colnames
        x = TimeArray(ds, 1:7, [:foo])
        y = TimeArray(ds, 1:7, [:bar])
        @test x != y
    end

    let  # Float vs Int
        x = TimeArray(ds, 1:7)
        y = TimeArray(ds, 1.0:7)
        @test x == y
    end

    let  # Date vs DateTime
        ds2 = Date(2017, 12, 25):Day(1):Date(2017, 12, 31) |> collect
        x = TimeArray(ds,  1:7, [:foo], :bar)
        y = TimeArray(ds2, 1:7, [:foo], :bar)
        @test x == y
    end

    let  # diff meta
        x = TimeArray(ds, 1:7, [:foo], :bar)
        y = TimeArray(ds, 1:7, [:foo], :baz)
        @test x != y
    end

    @testset "hash" begin
        @test hash(cl)   == hash(copy(cl))
        @test hash(ohlc) == hash(copy(ohlc))

        d = Dict(cl => 42)
        @test d[cl] == 42
        @test d[copy(cl)] == 42

        d = Dict(ohlc => 24)
        @test d[ohlc] == 24
        @test d[copy(ohlc)] == 24
    end
end


@testset "show methods don't throw errors" begin
    io = IOBuffer()
    let str = sprint(show, cl)
        out = "500×1 TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31"
        @test str == out
    end
    show(io, "text/plain", cl)
    let str = String(take!(io))
        out = """500×1 TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ 111.94 │
│ 2000-01-04 │ 102.5  │
│ 2000-01-05 │ 104.0  │
│ 2000-01-06 │ 95.0   │
│ 2000-01-07 │ 99.5   │
│ 2000-01-10 │ 97.75  │
│ 2000-01-11 │ 92.75  │
│ 2000-01-12 │ 87.19  │
│ 2000-01-13 │ 96.75  │
   ⋮
│ 2001-12-19 │ 21.62  │
│ 2001-12-20 │ 20.67  │
│ 2001-12-21 │ 21.0   │
│ 2001-12-24 │ 21.36  │
│ 2001-12-26 │ 21.49  │
│ 2001-12-27 │ 22.07  │
│ 2001-12-28 │ 22.43  │
│ 2001-12-31 │ 21.9   │"""
        @test str == out
    end

    # my edits above seem to work -- now need to do for the rest, JJS 2/22/19
    let str = sprint(show, ohlc)
        out = "500×4 TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31"
        @test str == out
    end
    show(io, "text/plain", ohlc)
    let str = String(take!(io))
        out = """500×4 TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2001-12-31
│            │ Open   │ High   │ Low    │ Close  │
├────────────┼────────┼────────┼────────┼────────┤
│ 2000-01-03 │ 104.88 │ 112.5  │ 101.69 │ 111.94 │
│ 2000-01-04 │ 108.25 │ 110.62 │ 101.19 │ 102.5  │
│ 2000-01-05 │ 103.75 │ 110.56 │ 103.0  │ 104.0  │
│ 2000-01-06 │ 106.12 │ 107.0  │ 95.0   │ 95.0   │
│ 2000-01-07 │ 96.5   │ 101.0  │ 95.5   │ 99.5   │
│ 2000-01-10 │ 102.0  │ 102.25 │ 94.75  │ 97.75  │
│ 2000-01-11 │ 95.94  │ 99.38  │ 90.5   │ 92.75  │
│ 2000-01-12 │ 95.0   │ 95.5   │ 86.5   │ 87.19  │
│ 2000-01-13 │ 94.48  │ 98.75  │ 92.5   │ 96.75  │
   ⋮
│ 2001-12-19 │ 20.58  │ 21.68  │ 20.47  │ 21.62  │
│ 2001-12-20 │ 21.4   │ 21.47  │ 20.62  │ 20.67  │
│ 2001-12-21 │ 21.01  │ 21.54  │ 20.8   │ 21.0   │
│ 2001-12-24 │ 20.9   │ 21.45  │ 20.9   │ 21.36  │
│ 2001-12-26 │ 21.35  │ 22.3   │ 21.14  │ 21.49  │
│ 2001-12-27 │ 21.58  │ 22.25  │ 21.58  │ 22.07  │
│ 2001-12-28 │ 21.97  │ 23.0   │ 21.96  │ 22.43  │
│ 2001-12-31 │ 22.51  │ 22.66  │ 21.83  │ 21.9   │"""
        @test str == out
    end

    let str = sprint(show, AAPL)
        out = "8336×12 TimeArray{Float64,2,Date,Array{Float64,2}} 1980-12-12 to 2013-12-31"
        @test str == out
    end
    show(io, "text/plain", AAPL)
    let str = String(take!(io))
        out = """8336×12 TimeArray{Float64,2,Date,Array{Float64,2}} 1980-12-12 to 2013-12-31
│            │ Open   │ High   │ Low    │ Close  │ Volume    │ Ex-Dividend │
├────────────┼────────┼────────┼────────┼────────┼───────────┼─────────────┤
│ 1980-12-12 │ 28.75  │ 28.88  │ 28.75  │ 28.75  │ 2.0939e6  │ 0.0         │
│ 1980-12-15 │ 27.38  │ 27.38  │ 27.25  │ 27.25  │ 785200.0  │ 0.0         │
│ 1980-12-16 │ 25.38  │ 25.38  │ 25.25  │ 25.25  │ 472000.0  │ 0.0         │
│ 1980-12-17 │ 25.88  │ 26.0   │ 25.88  │ 25.88  │ 385900.0  │ 0.0         │
│ 1980-12-18 │ 26.62  │ 26.75  │ 26.62  │ 26.62  │ 327900.0  │ 0.0         │
│ 1980-12-19 │ 28.25  │ 28.38  │ 28.25  │ 28.25  │ 217100.0  │ 0.0         │
│ 1980-12-22 │ 29.62  │ 29.75  │ 29.62  │ 29.62  │ 166800.0  │ 0.0         │
│ 1980-12-23 │ 30.88  │ 31.0   │ 30.88  │ 30.88  │ 209600.0  │ 0.0         │
│ 1980-12-24 │ 32.5   │ 32.62  │ 32.5   │ 32.5   │ 214300.0  │ 0.0         │
   ⋮
│ 2013-12-19 │ 549.5  │ 550.0  │ 543.73 │ 544.46 │ 1.14396e7 │ 0.0         │
│ 2013-12-20 │ 545.43 │ 551.61 │ 544.82 │ 549.02 │ 1.55862e7 │ 0.0         │
│ 2013-12-23 │ 568.0  │ 570.72 │ 562.76 │ 570.09 │ 1.79038e7 │ 0.0         │
│ 2013-12-24 │ 569.89 │ 571.88 │ 566.03 │ 567.67 │ 5.9841e6  │ 0.0         │
│ 2013-12-26 │ 568.1  │ 569.5  │ 563.38 │ 563.9  │ 7.286e6   │ 0.0         │
│ 2013-12-27 │ 563.82 │ 564.41 │ 559.5  │ 560.09 │ 8.0673e6  │ 0.0         │
│ 2013-12-30 │ 557.46 │ 560.09 │ 552.32 │ 554.52 │ 9.0582e6  │ 0.0         │
│ 2013-12-31 │ 554.17 │ 561.28 │ 554.0  │ 561.02 │ 7.9673e6  │ 0.0         │

│            │ Split Ratio │ Adj. Open │ Adj. High │ Adj. Low │ Adj. Close │
├────────────┼─────────────┼───────────┼───────────┼──────────┼────────────┤
│ 1980-12-12 │ 1.0         │ 3.3766    │ 3.3919    │ 3.3766   │ 3.3766     │
│ 1980-12-15 │ 1.0         │ 3.2157    │ 3.2157    │ 3.2004   │ 3.2004     │
│ 1980-12-16 │ 1.0         │ 2.9808    │ 2.9808    │ 2.9655   │ 2.9655     │
│ 1980-12-17 │ 1.0         │ 3.0395    │ 3.0536    │ 3.0395   │ 3.0395     │
│ 1980-12-18 │ 1.0         │ 3.1264    │ 3.1417    │ 3.1264   │ 3.1264     │
│ 1980-12-19 │ 1.0         │ 3.3179    │ 3.3331    │ 3.3179   │ 3.3179     │
│ 1980-12-22 │ 1.0         │ 3.4788    │ 3.494     │ 3.4788   │ 3.4788     │
│ 1980-12-23 │ 1.0         │ 3.6267    │ 3.6408    │ 3.6267   │ 3.6267     │
│ 1980-12-24 │ 1.0         │ 3.817     │ 3.8311    │ 3.817    │ 3.817      │
   ⋮
│ 2013-12-19 │ 1.0         │ 546.2492  │ 546.7463  │ 540.5133 │ 541.239    │
│ 2013-12-20 │ 1.0         │ 542.2033  │ 548.3467  │ 541.5969 │ 545.7721   │
│ 2013-12-23 │ 1.0         │ 564.6398  │ 567.3437  │ 559.4308 │ 566.7174   │
│ 2013-12-24 │ 1.0         │ 566.5186  │ 568.4968  │ 562.6814 │ 564.3117   │
│ 2013-12-26 │ 1.0         │ 564.7392  │ 566.1309  │ 560.0471 │ 560.564    │
│ 2013-12-27 │ 1.0         │ 560.4845  │ 561.071   │ 556.1901 │ 556.7766   │
│ 2013-12-30 │ 1.0         │ 554.1621  │ 556.7766  │ 549.0525 │ 551.2395   │
│ 2013-12-31 │ 1.0         │ 550.8916  │ 557.9595  │ 550.7226 │ 557.7011   │"""
        @test str == out
    end

    let str = sprint(show, ohlc[1:4])
        out = "4×4 TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2000-01-06"
        @test str == out
    end
    show(io, "text/plain", ohlc[1:4])
    let str = String(take!(io))
        out = """4×4 TimeArray{Float64,2,Date,Array{Float64,2}} 2000-01-03 to 2000-01-06
│            │ Open   │ High   │ Low    │ Close  │
├────────────┼────────┼────────┼────────┼────────┤
│ 2000-01-03 │ 104.88 │ 112.5  │ 101.69 │ 111.94 │
│ 2000-01-04 │ 108.25 │ 110.62 │ 101.19 │ 102.5  │
│ 2000-01-05 │ 103.75 │ 110.56 │ 103.0  │ 104.0  │
│ 2000-01-06 │ 106.12 │ 107.0  │ 95.0   │ 95.0   │"""
        @test str == out
    end


    let str = sprint(show, ohlc[1:0])
        @test str == "0×4 TimeArray{Float64,2,Date,Array{Float64,2}}"
    end
    show(io, "text/plain", ohlc[1:0])
    let str = String(take!(io))
        @test str == "0×4 TimeArray{Float64,2,Date,Array{Float64,2}}"
    end


    let str = sprint(show, TimeArray(Date[], []))
        @test str == "0×1 TimeArray{Any,1,Date,Array{Any,1}}"
    end
    show(io, "text/plain", TimeArray(Date[], []))
    let str = String(take!(io))
        @test str == "0×1 TimeArray{Any,1,Date,Array{Any,1}}"
    end

    let str = sprint(show, lag(cl[1:2], padding=true))
        out = "2×1 TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-04"
        @test str == out
    end
    show(io, "text/plain", lag(cl[1:2], padding=true))
    let str = String(take!(io))
        out = """2×1 TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2000-01-04
│            │ Close  │
├────────────┼────────┤
│ 2000-01-03 │ NaN    │
│ 2000-01-04 │ 111.94 │"""
        @test str == out
    end
end  # @testset "show methods don't throw errors"


@testset "getproperty" begin
    let
        @test cl.Close  == cl[:Close]
        @test_throws KeyError cl.NotFound
    end

    let
        @test ohlc.Open  == ohlc[:Open]
        @test ohlc.High  == ohlc[:High]
        @test ohlc.Low   == ohlc[:Low]
        @test ohlc.Close == ohlc[:Close]
        @test_throws KeyError ohlc.NotFound
    end
end


@testset "colnames should be copied" begin
    ts = Date(2019, 1, 1):Day(1):Date(2019, 1, 10)
    data = (ts = ts, A = 1:10)

    ta  = TimeArray(data, timestamp = :ts)
    ta′ = ta[6:10]

    colnames(ta′)[1] = :B

    @test length(ta)  == 10
    @test length(ta′) == 5

    @test colnames(ta)  == [:A]
    @test colnames(ta′) == [:B]
end


end  # @testset "timearray"
