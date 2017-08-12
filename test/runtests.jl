using Base.Test

tests = [
    "timearray",
    "split",
    "apply",
    "broadcast",
    "combine",
    "modify",
    "meta",
    "readwrite",
    "timeseriesrc",
    "deprecated",
]


@testset "TimeSeries" begin
    println("Running tests:")

    for test ∈ tests
        println("\t* $test ...")
        include("$test.jl")
    end
end
