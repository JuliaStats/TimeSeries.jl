using Base.Test

tests = [
    "timearray",
    "split",
    "apply",
    "combine",
    "modify",
    "meta",
    "readwrite",
    "timeseriesrc",
    "deprecated",
    "basemisc",
]


@testset "TimeSeries" begin
    println("Running tests:")

    for test ∈ tests
        println("\t* $test ...")
        include("$test.jl")
    end
end
